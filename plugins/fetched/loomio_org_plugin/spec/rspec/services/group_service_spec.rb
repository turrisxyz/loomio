require 'rails_helper'

describe 'GroupService' do
  let(:user) { create(:user) }
  let(:group) { build(:group) }

  describe 'create' do
    it 'creates a new trial subscription' do
      GroupService.create(group: group, actor: user)
      subscription = group.reload.subscription
      expect(subscription.state).to eq 'trialing'
    end
  end
end
