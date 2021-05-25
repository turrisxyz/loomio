class PagesController < ApplicationController
  Plugins::LoomioOrg::Plugin::LOOMIO_ORG_PAGES.each { |page| define_method page, ->{} }
  layout 'mhjb'

  before_action :set_locale_specific_links
  before_action :redirect_users_to_app, only: :index

  skip_after_action :set_xsrf_token
  helper_method :inline_stylesheet

  def index
    render template: "pages/mhjb_landing"
  end

  def working_from_home
    render template: "pages/working_from_home"
  end

  def pricing
    @pay = 'annually'
    @plans = SubscriptionService.plans_in_group('annual')

    if params[:pay] == 'monthly'
      @pay = 'monthly'
      @plans = SubscriptionService.plans_in_group('monthly')
    end


    if current_user.is_logged_in? and current_user.adminable_groups.parents_only.any?
      redirect_to '/upgrade'
    else
      render template: "pages/pricing"
    end
  end

  def pricing_community
    @plans = SubscriptionService.plans_in_group('community')
    render template: "pages/pricing_community"
  end

  private
  def redirect_users_to_app
    redirect_to "/dashboard" if current_user.is_logged_in? and !params.has_key?(:frontpage)
  end

  def inline_stylesheet(name)
   ('<style>'+(Rails.application.assets || ::Sprockets::Railtie.build_environment(Rails.application)).find_asset(name).to_s+'</style>').html_safe
  end

  def set_locale_specific_links
    case I18n.locale.to_s
    when 'es'
      @help_link = 'https://loomio.gitbooks.io/manual/content/es/index.html'
      @blog_link = 'http://blog.loomio.org/category/espanol-castellano/'
    else
      @help_link = 'https://help.loomio.org'
      @blog_link = 'https://blog.loomio.org/category/stories'
    end
  end
end
