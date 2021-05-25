class UpgradeController < ApplicationController
  layout 'mhjb'
  helper_method :subscription_for
  helper_method :psp_url
  before_action :require_sign_in, except: :please_sign_in
  helper_method :ssp_for
  helper_method :inline_stylesheet

  def index
    @groups = current_user.adminable_groups.published.parents_only.order(:full_name)
    redirect_to "/upgrade/#{@groups.first.id}" if @groups.length == 1
  end

  def cost
    subscription = current_user.adminable_groups.find(params[:group_id]).subscription
    info = SubscriptionService.next_charge(subscription.chargify_subscription_id)
    render json: info
  end

  def show
    @group = current_user.adminable_groups.find(params[:group_id])
    @survey = GroupSurvey.find_by(group_id: params[:group_id])

    case params[:pay]
    when 'monthly'
      @pay = 'monthly'
      @plans = SubscriptionService.plans_in_group('monthly')
    when 'community'
      @pay = 'community'
      @plans = SubscriptionService.plans_in_group('community')
    when 'annually'
      @pay = 'annually'
      @plans = SubscriptionService.plans_in_group('annual')
    else
      if @survey && @survey.category == 'community'
        @pay = 'community'
        @plans = SubscriptionService.plans_in_group('community')
      else
        @pay = 'annually'
        @plans = SubscriptionService.plans_in_group('annual')
      end
    end
  end

  def change
    @group = current_user.adminable_groups.find(params[:group_id])
    @subscription = @group.subscription

    if @subscription.owner.present?
      raise "user is not subscription creator" unless @subscription.owner == current_user
    end

    subscription_id = @subscription.chargify_subscription_id
    product_id = SubscriptionService::PLANS[params[:plan]][:chargify_product_id]
    response = SubscriptionService.change_plan(subscription_id, product_id)
    if response.code == 200
      redirect_to "/upgrade/#{@group.id}/change_complete"
    else
      @title = "Payment failed"
      @body = response['errors'].join(' ').to_s
      render '/application/error', layout: 'basic'
    end
  end

  def change_complete
    @group = current_user.adminable_groups.find(params[:group_id])
  end

  def preview_change
    @group = current_user.adminable_groups.find(params[:group_id])
    @subscription = @group.subscription
    subscription_id = @subscription.chargify_subscription_id
    product_id = SubscriptionService::PLANS[params[:plan]][:chargify_product_id]
    @plan_price = SubscriptionService::PLANS[params[:plan]][:price]
    @migration = SubscriptionService.preview_plan_change(subscription_id, product_id)
    @migration['plan_price'] = @plan_price.gsub(',','').to_i*100
    @migration['credit_on_current_plan'] = @migration['charge_in_cents'] - @migration['plan_price']
    amount_due = @migration['plan_price'] + @migration['balance_in_cents'] + @migration['prorated_adjustment_in_cents']
    if amount_due > 0
      @migration['amount_due'] = amount_due
      @migration['credit_remaining'] = 0
    else
      @migration['amount_due'] = 0
      @migration['credit_remaining'] = amount_due
    end
  end

  def complete
    update_subscription
  end

  def update_subscription
    chargify_subscription = SubscriptionService.chargify_get(params[:subscription_id])
    @group = current_user.adminable_groups.find_by(key: chargify_subscription['customer']['reference'].split('-').first)
    subscription = Subscription.for(@group)
    SubscriptionService.update(subscription: subscription, params: chargify_subscription)
  end

  def community
    @group = current_user.adminable_groups.find(params[:group_id])
  end

  def please_sign_in
  end

  private
  def inline_stylesheet(name)
   ('<style>'+(Rails.application.assets || ::Sprockets::Railtie.build_environment(Rails.application)).find_asset(name).to_s+'</style>').html_safe
  end

  def group_survey_params
    params.require(:group_survey).permit(:group_id, :category, :location, :size, :purpose, :referrer, :role, :website, :misc, :usage => [])
  end

  def require_sign_in
    render 'please_sign_in' unless current_user.is_logged_in?
  end

  def subscription_for(group)
    Subscription.for(group)
  end
end
