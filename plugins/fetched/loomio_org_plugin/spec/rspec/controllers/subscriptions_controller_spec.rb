require 'rails_helper'

describe SubscriptionsController do

  let(:user) { create :user }
  let(:group) { create :group }

  before do
    SubscriptionsController.any_instance.stub(:verify_request).and_return(true)
    GroupService.create(group: group, actor: user)
  end

  describe 'new group' do
    it 'has a trial subscription' do
      expect(group.subscription.state).to eq "trialing"
    end
  end

  describe 'webhook' do

    it 'signup_success' do
      post :webhook, params: {
        event: :signup_success,
        payload: {
          subscription: {
            id: '123456789',
            state: "active",
            product:  { id: 4763868, handle: 'small-monthly'},
            customer: { reference: "#{group.id}-#{Time.now.to_i}" }
          }
        }
      }
      subscription = group.subscription.reload
      expect(subscription.plan).to        eq 'small-monthly'
      expect(subscription.state).to       eq 'active'
      expect(subscription.max_members).to eq 50
      expect(subscription.max_threads).to eq nil
      expect(subscription.expires_at).to  eq nil
      expect(response.status).to eq 200
    end

    it 'performs a subscription_product_change' do
      group.subscription.update(plan: "small-monthly", max_members: 50)

      post :webhook, params: {
        event: :subscription_product_change,
        payload: {
          subscription: {
            id: '123456789',
            state: "active",
            product:  { id: 4763870, handle: 'large-monthly'},
            customer: { reference: "#{group.id}-#{Time.now.to_i}" }
          }
        }
      }

      subscription = group.subscription.reload
      expect(subscription.plan).to        eq 'large-monthly'
      expect(subscription.state).to       eq 'active'
      expect(subscription.max_members).to eq 5000
      expect(response.status).to eq 200
    end

    it 'performs a subscription_state_change' do
      group.subscription.update(state: "active", plan: "small-monthly", max_members: 32)

      post :webhook, params: {
        event: :subscription_state_change,
        payload: {
          subscription: {
            id: '1234567890',
            state: "canceled",
            product:  { id: 4763868, handle: 'small-monthly'},
            customer: { reference: "#{group.id}-#{Time.now.to_i}" }
          }
        }
      }

      subscription = group.subscription.reload
      expect(subscription.max_members).to eq 32
      expect(subscription.plan).to eq 'small-monthly'
      expect(subscription.state).to eq 'canceled'
      expect(response.status).to eq 200
    end
  end
end
