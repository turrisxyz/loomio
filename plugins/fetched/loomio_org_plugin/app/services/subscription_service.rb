class SubscriptionService
  SIGN_UP_BASE_URL = "https://loomio.chargifypay.com/subscribe/"
  UPDATE_DAILY =   %w[pp-basic-monthly pp-pro-monthly ap-active-monthly npap-active-monthly]
  UPDATE_MONTHLY = %w[pp-basic-annual pp-pro-annual pp-community-annual ap-active-annual ap-community-annual npap-active-annual]
  PP_PLANS = %w[pp-basic-annual pp-pro-annual pp-community-annual pp-basic-monthly pp-pro-monthly]
  USABLE_PLANS = %w[ap-active-monthly ap-active-annual ap-community-annual pp-basic-monthly pp-pro-monthly pp-basic-annual pp-pro-annual pp-community-annual npap-active-monthly npap-active-annual]
  CURRENT_PLANS = %w[2021-starter-monthly 2021-nonprofit-monthly 2021-pro-monthly 2021-starter-annual 2021-community-lifetime 2021-nonprofit-annual 2021-pro-annual]
  PLANS = {
    '2021-starter-monthly':    {max_members: nil, max_threads: nil, chargify_product_id: 5455558, group: 'monthly', path: "q5ndw92fn6yy/2021-starter-monthly", price: '25', savings: 101, level: :starter, benefits: %w[30_day_free_trial unlimited_members unlimited_discussions unlimited_subgroups integrate_slack]},
    '2021-pro-monthly':        {max_members: nil, max_threads: nil, chargify_product_id: 5460795, group: 'monthly', path: "jvpcd9zpsq5t/2021-pro-monthly", price: '149', savings: 489, level: :pro, benefits: %w[30_day_free_trial unlimited_members unlimited_discussions unlimited_subgroups integrate_slack sso dedicated_expert implementation_support priority_support premium_features_coming_soon]},
    '2021-nonprofit-monthly':  {max_members: nil, max_threads: nil, chargify_product_id: 5460797, group: 'monthly', path: "dy2zpd8qjz87/2021-nonprofit-monthly", price: '75', savings: 251, level: :nonprofit, benefits: %w[30_day_free_trial unlimited_members unlimited_discussions unlimited_subgroups integrate_slack sso dedicated_expert implementation_support  priority_support premium_features_coming_soon]},
    '2021-starter-annual':     {max_members: nil, max_threads: nil, chargify_product_id: 5455559, group: 'annual',  path: "qyx3qsf37ffp/2021-starter-annual", price: '199', level: :starter, benefits: %w[30_day_free_trial unlimited_members unlimited_discussions unlimited_subgroups integrate_slack]},
    '2021-pro-annual':         {max_members: nil, max_threads: nil, chargify_product_id: 5460796, group: 'annual', path: "hgyhxtj2zts2/2021-pro-annual", price: '1,299', level: :pro, benefits: %w[30_day_free_trial unlimited_members unlimited_discussions unlimited_subgroups integrate_slack sso dedicated_expert implementation_support priority_support premium_features_coming_soon 199_credit]},
    '2021-nonprofit-annual':   {max_members: nil, max_threads: nil, chargify_product_id: 5460798, group: 'annual', path: "wt7gssk7nrrz/2021-nonprofit-annual", price: '649', level: :nonprofit, benefits: %w[30_day_free_trial unlimited_members unlimited_discussions unlimited_subgroups integrate_slack sso dedicated_expert implementation_support priority_support premium_features_coming_soon]},
    '2021-community-lifetime': {max_members: nil, max_threads: nil, chargify_product_id: 5460793, group: 'community', path: "3cdmvpht996y/2021-community-lifetime", price: '199', level: :community, benefits: %w[lifetime_subscription unlimited_members unlimited_discussions unlimited_subgroups integrate_slack]},
    'npap-active-monthly':     {max_members: nil, max_threads: nil, chargify_product_id: 5248485, component_id: 1006966, path: "rkjvb9qvrvq6/npap-active-monthly"},
    'npap-active-annual':      {max_members: nil, max_threads: nil, chargify_product_id: 5248486, component_id: 1006968, path: "8qxm4zhcs8ts/npap-active-annual"},
    'ap-active-monthly':       {max_members: nil, max_threads: nil, chargify_product_id: 5231511, component_id: 981874, path: "5vx33p5xtx4x/ap-active-monthly"},
    'ap-active-annual':        {max_members: nil, max_threads: nil, chargify_product_id: 5232786, component_id: 983195, path: "z7p5s29srghm/ap-active-annual", accrue_charge: false },
    'ap-community-annual':     {max_members: nil, max_threads: nil, chargify_product_id: 5234303, component_id: 985125, path: "d8cyq7ht73pm/ap-community-annual", accrue_charge: false },
    'pp-basic-monthly':        {max_members: nil, max_threads: nil, chargify_product_id: 5024017, component_id: 782964, path: "vcwmy7z45g5f/pp-basic-monthly"},
    'pp-basic-annual':         {max_members: nil, max_threads: nil, chargify_product_id: 5061732, component_id: 815321, path: "3xgqnh2b9nxs/pp-basic-yearly", accrue_charge: false},
    'pp-pro-monthly':          {max_members: nil, max_threads: nil, chargify_product_id: 5029076, component_id: 815322, path: "snpqtjb8vys8/pp-pro-monthly"},
    'pp-pro-annual':           {max_members: nil, max_threads: nil, chargify_product_id: 5061733, component_id: 815323, path: "xnkgwv7hjygf/pp-pro-yearly", accrue_charge: false},
    'pp-community-annual':     {max_members: nil, max_threads: nil, chargify_product_id: 5061734, component_id: 815324, path: "ntdzkv8bx44p/pp-community-yearly", accrue_charge: false},
    'free':                    {max_members: nil, max_threads: nil, chargify_product_id: nil},
    'trial':                   {max_members: 20,  max_threads: 20,  chargify_product_id: nil},
    'was-gift':                {max_members: nil, max_threads: nil, chargify_product_id: nil},
    'was-paid':                {max_members: nil, max_threads: nil, chargify_product_id: nil},
    'small-monthly':           {max_members: 50,  max_threads: nil, chargify_product_id: 4763868},
    'small-yearly':            {max_members: 50,  max_threads: nil, chargify_product_id: 4763871},
    'medium-monthly':          {max_members: 500, max_threads: nil, chargify_product_id: 4763869},
    'medium-yearly':           {max_members: 500, max_threads: nil, chargify_product_id: 4763872},
    'large-monthly':           {max_members: 5000, max_threads: nil, chargify_product_id: 4763870},
    'large-yearly':            {max_members: 5000, max_threads: nil, chargify_product_id: 4763873},
    'standard-loomio-plan':    {max_members: 100,  max_threads: nil, chargify_product_id: 3725481},
    'gold-plan-yearly':        {max_members: 100,  max_threads: nil, chargify_product_id: 3745869},
    'pro-loomio-plan':         {max_members: 1000, max_threads: nil, chargify_product_id: 3905329},
    'pro-plan-yearly':         {max_members: 1000, max_threads: nil, chargify_product_id: 3905929},
    'plus-plan-yearly':        {max_members: 1000, max_threads: nil, chargify_product_id: 3751697},
    'plus-plan':               {max_members: 1000, max_threads: nil, chargify_product_id: 3731191},
    'action-station-plan':     {max_members: nil,  max_threads: nil, chargify_product_id: 3763837}
  }.with_indifferent_access.map do |plan, config|
    config[:plan] = plan
    [plan, config]
  end.to_h.with_indifferent_access

  def self.plans_in_group(group)
    PLANS.filter {|k,v| v[:group] == group }
  end

  def self.available?
    ENV['CHARGIFY_APP_NAME'] && ENV['CHARGIFY_API_KEY']
  end

  # called by chargify webhook
  def self.update(subscription:, params:, previous_product_params: nil)
    product_id = params['product']['id']
    handle, plan = plan_by_chargify_product_id(product_id).shift

    subscription.update(plan.slice(:max_members, :max_threads, :chargify_product_id)) if subscription.plan != handle

    subscription.update!({ payment_method:           :chargify,
                           activated_at:             params['activated_at'],
                           canceled_at:              params['canceled_at'],
                           expires_at:               params['expires_at'],
                           renews_at:                params['next_assessment_at'],
                           renewed_at:               params['current_period_started_at'],
                           plan:                     handle,
                           state:                    params['state'],
                           chargify_subscription_id: params['id'],
                           info: (subscription.info || {}).merge({
                             'chargify_referral_code': params['referral_code'],
                             'chargify_next_assessment_at': params['next_assessment_at'],
                             'chargify_customer_id': params['customer']['id']
                              })
                           })

    # if previous_product_params
    #   # if product changes we need to tell chargify to update the old component (i.e. reduce the component quantity to 0)
    #   update_chargify_component_on_product_change(chargify_subscription_id: subscription.chargify_subscription_id, previous_plan: previous_product_params['handle'])
    #   # then tell chargify to update the members count on the new component
    #   subscription.update_members_count!
    # end
  end

  def self.plan_by_chargify_product_id(id)
    PLANS.select {|k, v| v['chargify_product_id'] == id.to_i }
  end

  def self.chargify_get(id)
    response = HTTParty.get "https://#{ENV['CHARGIFY_APP_NAME']}.chargify.com/subscriptions/#{id}.json",
                            basic_auth: {username: ENV['CHARGIFY_API_KEY'], password: 'X'}
    response['subscription']
  end

  def self.cancel(group:)
    subscription = Subscription.for(group)
    if subscription.payment_method == "chargify"
      HTTParty.delete "https://#{ENV['CHARGIFY_APP_NAME']}.chargify.com/subscriptions/#{subscription.chargify_subscription_id}.json",
                      basic_auth: {username: ENV['CHARGIFY_API_KEY'], password: 'X'}
    end
    subscription.update(state: 'canceled')
  end

  def self.preview_plan_change(chargify_subscription_id, chargify_product_id)
    sub = HTTParty.get "https://#{ENV['CHARGIFY_APP_NAME']}.chargify.com/subscriptions/#{chargify_subscription_id}.json",
                    basic_auth: {username: ENV['CHARGIFY_API_KEY'], password: 'X'}
    response = HTTParty.post "https://#{ENV['CHARGIFY_APP_NAME']}.chargify.com/subscriptions/#{chargify_subscription_id}/migrations/preview.json",
                    basic_auth: {username: ENV['CHARGIFY_API_KEY'], password: 'X'},
                    body: {product_id: chargify_product_id, include_initial_charge: 1}
    raise response.to_s if response.code != 200
    obj = response['migration']
    obj['balance_in_cents'] = sub['subscription']['balance_in_cents']
    obj
  end

  def self.change_plan(chargify_subscription_id, chargify_product_id)
    HTTParty.post "https://#{ENV['CHARGIFY_APP_NAME']}.chargify.com/subscriptions/#{chargify_subscription_id}/migrations.json",
        basic_auth: {username: ENV['CHARGIFY_API_KEY'], password: 'X'},
        body: {product_id: chargify_product_id, include_initial_charge: 1}
  end

  def self.next_charge(chargify_subscription_id)
    response = HTTParty.post "https://#{ENV['CHARGIFY_APP_NAME']}.chargify.com/subscriptions/#{chargify_subscription_id}/renewals/preview.json",
                    basic_auth: {username: ENV['CHARGIFY_API_KEY'], password: 'X'}
    raise response.to_s if response.code != 200
    response['renewal_preview']
  end

  def self.new_trial
    trial_days = ENV.fetch('TRIAL_DAYS', 30).to_i
    subscription = Subscription.new(PLANS['trial'].merge(state: 'trialing', expires_at: trial_days.days.from_now))
    subscription
  end

  def self.populate_management_links
    Subscription.where.not(plan: ["was-gift", "trial", "free"]).where(state: 'active').where.not(chargify_subscription_id: nil).where("(info -> 'chargify_management_link') is null").find_each do |subscription|
      subscription.refresh_management_link!
    end
  end

  def self.refresh_expiring_management_links
    # where there is a management link and expires_at,
    # and where expires_at is exceeded by the date 2 weeks from now
    # i.e. (going to expire within the next 2 weeks)
    Subscription.where.not(plan: ["was-gift", "trial", "free"]).where(state: 'active').where.not(chargify_subscription_id: nil).where("(info -> 'chargify_management_link') is not null").where("(info -> 'chargify_management_link_expires_at') is not null").where("(info ->> 'chargify_management_link_expires_at') < ?", 2.weeks.from_now).find_each do |subscription|
      subscription.refresh_management_link!
    end
  end

  def self.update_chargify_component_on_product_change(chargify_subscription_id:, previous_plan:)
    previous_component_id = PLANS[previous_plan]['component_id']
    return unless previous_component_id # guard against this happening for old plans
    HTTParty.post("https://#{ENV['CHARGIFY_APP_NAME']}.chargify.com/subscriptions/#{chargify_subscription_id}/components/#{previous_component_id}/allocations.json", {basic_auth: {username: ENV['CHARGIFY_API_KEY'], password: 'X'}, body: { allocation: { quantity: 0 } }})
  end

  def self.update_chargify_component_allocation(chargify_subscription_id:, plan:, count:)
    plan_info = PLANS[plan]
    body = { allocation: { quantity: count }, accrue_charge: plan_info[:accrue_charge] }.compact
    if ENV['DEBUG_SUBSCRIPTIONS']
      subscription = Subscription.find_by(chargify_subscription_id: chargify_subscription_id)
      group = Group.where(subscription_id: subscription.id).first
      puts "Subscription #{subscription.id} #{plan}, Group #{group.id} #{group.name}, Members: #{count}"
      s = Struct.new(:code)
      return s.new(400)
    else
      HTTParty.post("https://#{ENV['CHARGIFY_APP_NAME']}.chargify.com/subscriptions/#{chargify_subscription_id}/components/#{plan_info[:component_id]}/allocations.json", {basic_auth: {username: ENV['CHARGIFY_API_KEY'], password: 'X'}, body: body})
    end
  end

  def self.update_member_counts
    Subscription.active.where(plan: UPDATE_DAILY).find_each(&:update_members_count!)

    if Date.today.mday == 1
      Subscription.active.where(plan: UPDATE_MONTHLY).find_each(&:update_members_count!)
    end
  end

  def self.psp_url(group, user, plan_key)
    return unless group.subscription
    args = {first_name: user.first_name,
            last_name: user.last_name,
            email: user.email,
            reference: "#{group.key}-#{Time.now.to_i}",
            organization: group.name,
          }
    plan = SubscriptionService::PLANS[plan_key]
    # SubscriptionService::SIGN_UP_BASE_URL + plan[:path]  + "?" + URI.encode_www_form(args) + "&components[#{plan[:component_id]}][allocated_quantity]=#{group.subscription.count_members}"
    SubscriptionService::SIGN_UP_BASE_URL + plan[:path]  + "?" + URI.encode_www_form(args)
  end

end
