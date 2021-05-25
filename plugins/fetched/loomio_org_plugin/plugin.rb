module Plugins
  module LoomioOrg
    class Plugin < Plugins::Base
      setup! :loomio_org_plugin do |plugin|
        LOOMIO_ORG_PAGES = %w(
          browser_not_supported
          bcorp
        )

        LOOMIO_ORG_PAGES.each { |page| plugin.use_page page, "pages##{page}" }

        %w(governance
        private_host
        collaboration
        engagement).each do |page|
          plugin.use_page page, 'https://www.loomio.org?frontpage', redirect: true
        end

        plugin.use_page :help,             'https://help.loomio.org', redirect: true
        plugin.use_page :blog,             'https://blog.loomio.org', redirect: true
        plugin.use_page :press,            'https://blog.loomio.org/press-pack', redirect: true
        plugin.use_page :"press-pack",     'https://blog.loomio.org/press-pack', redirect: true
        plugin.use_page :translation,      'https://www.transifex.com/rdbartlett/loomio-1/', redirect: true
        plugin.use_page :privacy,          'https://help.loomio.org/en/legal/privacy', redirect: true
        plugin.use_page :terms_of_service, 'https://help.loomio.org/en/legal/terms_of_service', redirect: true
        plugin.use_page :third_parties,    'https://help.loomio.org/en/legal/third_parties', redirect: true
        plugin.use_page :gdpr,             'https://help.loomio.org/en/legal/gdpr', redirect: true
        plugin.use_page :about,            'https://help.loomio.org/en/about/', redirect: true
        plugin.use_page :special_pricing,  'https://www.loomio.org/pricing/community/', redirect: true
        plugin.use_page '/pricing/non_profit',    'https://www.loomio.org/pricing', redirect: true

        plugin.use_page '/',                      'pages#index'
        plugin.use_page '/intro',                 'pages#index'
        plugin.use_page '/working-from-home',     'pages#working_from_home'
        plugin.use_page '/pricing',               'pages#pricing'
        plugin.use_page '/pricing/community',     'pages#pricing_community'
        plugin.use_page '/upgrade',               'upgrade#index'
        plugin.use_page '/upgrade/cost',          'upgrade#cost'
        plugin.use_page '/upgrade/:group_id/preview_change', 'upgrade#preview_change'
        plugin.use_route :post, '/upgrade/:group_id/change', 'upgrade#change'
        plugin.use_page '/upgrade/:group_id/change_complete', 'upgrade#change_complete'
        plugin.use_page '/upgrade/:group_id',     'upgrade#show'
        plugin.use_page '/please_sign_in',        'upgrade#please_sign_in'
        plugin.use_page '/upgrade/complete',      'upgrade#complete'
        plugin.use_page '/upgrade/community',     'upgrade#community'
        plugin.use_page '/subscriptions/webhook', 'subscriptions#webbook'

        plugin.use_static_asset_directory :'app/assets/stylesheets/', standalone: true
        plugin.use_static_asset_directory :"app/assets/images/", standalone: true
        plugin.use_static_asset_directory :"app/assets/javascripts/", standalone: true

        plugin.use_translations 'config/locales', :marketing

        plugin.use_view_path       'app/views'
        plugin.use_class_directory 'config/initializers'
        plugin.use_class_directory 'app/controllers'
        plugin.use_class_directory 'app/services'
        plugin.use_class_directory 'app/models'

        plugin.use_events do |event_bus|
          event_bus.listen('session_create', 'registration_create', 'boot_site') do |user|
            CustomerioService.delay.identify(user.id) if user.is_logged_in?
          end

          event_bus.listen('group_survey_create') do |survey, actor|
            args = survey.slice(:category, :location, :size, :usage, :referrer, :role, :website, :desired_feature, :segment)
            group = survey.group
            args.merge!({
              group_id: group.id,
              group_name: group.name,
              group_key: group.key,
              group_handle:  group.handle
            })

            CustomerioService.track(actor.id, 'group_survey_create', survey, args)
          end

          event_bus.listen('group_invite') do |group, actor, count|
            CustomerioService.track(actor.id, 'group_invite', group, {count: count})
          end

          # event_bus.listen('discussion_create') do |discussion, actor|
          #   CustomerioService.track(actor.id, 'discussion_create', discussion)
          # end
          #
          # event_bus.listen('poll_create') do |poll, actor|
          #   CustomerioService.track(actor.id, 'poll_create', poll)
          # end
          #
          # event_bus.listen('outcome_create') do |outcome, actor|
          #   CustomerioService.track(actor.id, 'outcome_create', outcome)
          # end
          #
          # event_bus.listen('comment_create') do |comment, actor|
          #   CustomerioService.track(actor.id, 'comment_create', comment)
          # end
          #
          # event_bus.listen('stance_create') do |stance, actor|
          #   CustomerioService.track(actor.id, 'stance_create', stance)
          # end

          # event_bus.listen('reaction_create') do |reaction, actor|
          #   CustomerioService.delay.track(actor.id, 'reaction_create', reaction)
          # end

          event_bus.listen('group_create') do |group, actor|
            if group.is_parent?
              group.subscription = SubscriptionService.new_trial
              group.save!
            end
          end

          event_bus.listen('group_create') do |group, actor|
            if group.subscription && group.subscription.state == 'trialing'
              args = group.slice(:name, :id, :key, :handle)
              CustomerioService.track(actor.id, 'start_group_trial', group, args)
            end
          end

          event_bus.listen('group_archive', 'group_destroy') do |group|
            SubscriptionService.cancel(group: group) if group.is_parent? && Group.published.where(subscription_id: group.subscription_id, parent_id: nil).where.not(id: group.id).none?
          end
        end

        plugin.use_test_route :setup_group_on_free_plan do
          group = Group.new(name: 'Ghostbusters', is_visible_to_public: true)
          GroupService.create(group: group, actor: patrick)
          group.subscription.update(plan: 'free', max_members: nil, max_threads: nil)
          group.add_member! jennifer
          sign_in patrick
          redirect_to group_url(group)
        end

        plugin.use_test_route :setup_group_on_trial_plan do
          group = Group.new(name: 'Ghostbusters', is_visible_to_public: true)
          GroupService.create(group: group, actor: patrick)
          group.add_member! jennifer
          sign_in patrick
          redirect_to group_url(group)
        end

        plugin.use_test_route :setup_group_on_finished_trial_plan do
          group = Group.new(name: 'Ghostbusters', is_visible_to_public: true)
          GroupService.create(group: group, actor: patrick)
          group.subscription.update(plan: 'trial', max_members: 1, max_threads: 1)
          group.add_member! jennifer
          sign_in patrick
          redirect_to group_url(group)
        end

        plugin.use_test_route :setup_group_on_starter_plan do
          create_group.save
          GroupService.create(group: create_group, actor: patrick)
          create_group.subscription.update(plan: '2021-starter', max_members: nil, max_threads: nil, state: :active, renews_at: 6.months.from_now, renewed_at: 6.months.ago)
          sign_in patrick
          Membership.find_by(user: patrick, group: create_group).update(created_at: 1.week.ago)
          redirect_to group_url(create_group)
        end

        plugin.use_test_route :setup_group_on_community_plan do
          create_group.save
          GroupService.create(group: create_group, actor: patrick)
          create_group.subscription.update(plan: '2021-community')
          sign_in patrick
          Membership.find_by(user: patrick, group: create_group).update(created_at: 1.week.ago)
          redirect_to group_url(create_group)
        end

        plugin.use_test_route :setup_group_on_small_plan do
          create_group.save
          GroupService.create(group: create_group, actor: patrick)
          create_group.subscription.update(plan: 'small-monthly')
          sign_in patrick
          Membership.find_by(user: patrick, group: create_group).update(created_at: 1.week.ago)
          redirect_to group_url(create_group)
        end

        # plugin.use_test_route :setup_group_on_paid_plan_as_non_coordinator do
        #   GroupService.create(group: create_group, actor: patrick)
        #   subscription = create_group.subscription
        #   subscription.update_attribute :kind, 'paid'
        #   sign_in jennifer
        #   redirect_to group_url(create_group)
        # end
      end
    end
  end
end
