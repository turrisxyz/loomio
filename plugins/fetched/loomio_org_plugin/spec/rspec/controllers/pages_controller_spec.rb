require 'rails_helper'
require_relative '../../../app/controllers/pages_controller'

describe PagesController, type: :controller do
  render_views
  let(:spanish_user) { create(:user, selected_locale: :es) }

  describe 'marketing' do
    it 'takes you to the marketing page when logged out' do
      get :index
      expect(response.status).to eq 200
    end

    it 'takes you to the marketing page when logged in' do
      sign_in create(:user)
      get :index
      expect(response).to redirect_to dashboard_path
    end
  end

  describe 'pages' do
    Plugins::LoomioOrg::Plugin::LOOMIO_ORG_PAGES.each do |page|
      let(:user) { create :user }
      let(:group) { create :group }

      it "renders /#{page} for logged out users" do
        get page
        expect(response.status).to eq 200
        expect(response).to render_template page
      end

      it "renders /#{page} for logged in users" do
        group.add_member! user
        sign_in user
        get page
        expect(response.status).to eq 200
        expect(response).to render_template page
      end
    end
  end
end
