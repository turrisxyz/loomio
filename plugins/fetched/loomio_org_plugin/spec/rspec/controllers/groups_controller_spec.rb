require 'rails_helper'
describe GroupsController do

  let(:user) { create :user }
  let(:group) { create :group }

  before do
    sign_in user
    group.save
  end

  describe 'export' do
    it 'exports for admins' do
      group.add_admin! user
      get :export, params: { key: group.key }
      expect(response.status).to eq 200
      expect(response).to render_template :export
    end

    it 'does not export for group members' do
      group.add_member! user
      get :export, params: { key: group.key }
      expect(response).to redirect_to dashboard_path
      expect(flash[:error]).to be_present
    end
  end
end
