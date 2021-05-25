class SubscriptionsController < ApplicationController
  before_action :verify_request, only: :webhook
  helper_method :inline_stylesheet

  def webhook
    if SubscriptionService.available?
      SubscriptionService.update(
        subscription: subscription,
        params: webhook_params['subscription'],
        previous_product_params: webhook_params['previous_product']
      )
      head :ok
    else
      head :bad_request
    end
  end

  private

  def inline_stylesheet(name)
   ('<style>'+(Rails.application.assets || ::Sprockets::Railtie.build_environment(Rails.application)).find_asset(name).to_s+'</style>').html_safe
  end
  
  def webhook_params
    params.require(:payload).permit(subscription: {}, site: {}, transaction: {}, previous_product: {})
  end

  def group
    group_key = webhook_params['subscription']['customer']['reference'].sub("|", "-").split('-')[0]
    Group.find(group_key)
  end

  def subscription
    Subscription.for(group)
  end

  def verify_request
    given_signature    = request.headers["HTTP_X_CHARGIFY_WEBHOOK_SIGNATURE_HMAC_SHA_256"]
    computed_signature = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'),
                                                 ENV['CHARGIFY_SITE_KEY'],
                                                 request.raw_post)

    head :forbidden unless (given_signature == computed_signature)
  end

end
