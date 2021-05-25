require_relative Rails.root.join 'app/models/subscription.rb'

class Subscription
  ACTIVE_PLANS = %w[ap-active-monthly ap-active-annual ap-community-annual trial npap-active-monthly npap-active-annual]
  ACCEPTED_PLANS = %w[pp-basic-monthly pp-pro-monthly pp-basic-annual pp-pro-annual pp-community-annual]
  ACTIVE_EVENTS = %w[new_discussion poll_created new_comment stance_created]

  scope :active, -> { where(state: 'active') }

  def assistance_required?
    !(self.plan == 'trial' || self.state == 'active')
  end
  
  def update_members_count!
    count = count_members
    if self.members_count != count && chargify_subscription_id
      response = SubscriptionService.update_chargify_component_allocation(chargify_subscription_id: chargify_subscription_id, plan: plan, count: count)
      update(members_count: count) if [200, 201].include? response.code # if request fails, we want to try again to ensure that chargify has the right information
    end
  end

  def count_members
    if ACTIVE_PLANS.include? plan
      count_active_members
    else
      count_accepted_members
    end
  end

  def count_active_members(date_range = active_member_date_range)
    all_group_and_subgroup_ids = parent_groups.map { |parent| parent.id_and_subgroup_ids }.flatten
    Event.where(user_id: Membership.active.where(group_id: all_group_and_subgroup_ids).pluck(:user_id).compact, kind: ACTIVE_EVENTS).where(created_at: date_range).count('distinct user_id')
  end

  def active_member_date_range
    if plan == 'ap-active-monthly'
      renewed_at..(renews_at || renewed_at + 1.month)
    else
      1.month.ago.to_date..Date.tomorrow
    end
  end

  def count_accepted_members
    all_group_and_subgroup_ids = parent_groups.map { |parent| parent.id_and_subgroup_ids }.flatten
    Membership.active.where(group_id: all_group_and_subgroup_ids).count('distinct user_id')
  end

  def parent_groups
    Group.where(subscription_id: self.id)
  end

  def refresh_management_link!
    return unless self.info && self.info['chargify_customer_id']
    customer_id = self.info['chargify_customer_id']
    response = HTTParty.get "https://#{ENV['CHARGIFY_APP_NAME']}.chargify.com/portal/customers/#{customer_id}/management_link.json",
                            basic_auth: {username: ENV['CHARGIFY_API_KEY'], password: 'X'}
    return unless response && response['url']
    management_link = response['url']
    management_link_expires_at = response['expires_at']
    self.update({ info: (self.info || {}).merge({
      "chargify_management_link": management_link,
      "chargify_management_link_expires_at": management_link_expires_at })
    })
  end
end
