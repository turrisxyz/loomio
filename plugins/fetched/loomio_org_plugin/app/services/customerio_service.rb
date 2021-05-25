module CustomerioService
  def self.track(user_id, action, model, args = {})
    return unless ENV['CUSTOMERIO_ID']
    self.delay.real_track(user_id, action, args)
  end

  def self.real_track(user_id, action, args)
    identify(user_id)
    $customerio.track(user_id, action, args)
  end

  def self.identify(user_id)
    return unless ENV['CUSTOMERIO_ID'] and user_id
    attrs = {}
    return unless user = User.find_by(id: user_id)

    main_group = Group.where(parent_id: nil, id: user.adminable_group_ids).order(memberships_count: :desc).first
    return unless main_group
    main_subscription = Subscription.where(owner_id: user.id).last || (main_group && main_group.subscription)

    attrs['admin_groups_count'] = user.adminable_groups.count
    attrs['subscriptions_count'] = Subscription.where(owner_id: user.id).count

    user_attrs = user.slice %w(id email name first_name username created_at last_sign_in_at last_seen_at locale country email_newsletter)
    user_attrs[:timezone] = user.time_zone
    user_attrs.each_pair do |key, value|
      if key.ends_with?('_at')
        attrs[key] = value.to_i
      else
        attrs[key] = value
      end
    end

    if main_group && main_survey = GroupSurvey.where(group_id: main_group.id).last
      survey_attrs = main_survey.slice %w(
        category
        location
        size
        usage
        referrer
        role
        website
        created_at
        updated_at
        desired_feature
        segment
      )

      survey_attrs.each_pair do |key, value|
        attrs['survey_'+key] = key.ends_with?('_at') ? value.to_i : value
      end
    end

    user_attrs.each_pair do |key, value|
      attrs[key] = key.ends_with?('_at') ? value.to_i : value
    end

    if main_group
      main_group_attrs = main_group.slice(
        :org_members_count,
        :org_discussions_count,
        :org_polls_count,
        :subgroups_count,
        :name,
        :id,
        :handle)
      main_group_attrs.each_pair do |key, value|
        attrs['main_group_'+key] = key.ends_with?('_at') ? value.to_i : value
      end
    end

    if main_subscription
      main_subscription_attrs = main_subscription.slice(
        :plan,
        :state,
        :activated_at,
        :expires_at,
        :renews_at,
        :renewed_at,
        :canceled_at,
        :payment_method,
        :members_count,
        :chargify_subscription_id
      )

      main_subscription_attrs.each_pair do |key, value|
        attrs['main_subscription_'+key] = key.ends_with?('_at') ? value.to_i : value
      end
    end

    $customerio.identify(attrs)
  end
end
