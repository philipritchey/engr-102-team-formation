require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  describe "GET #show" do
    let(:user) { create(:user) }
    let!(:user_forms) { create_list(:form, 3, user: user) }
    let!(:other_forms) { create_list(:form, 2) }

    before do
      # Simulate user login
      allow(controller).to receive(:current_user).and_return(user)
      get :show, params: { id: user.id }
    end

    it "returns a success response" do
      expect(response).to be_successful
    end

    it "assigns @forms with the current user's forms" do
      expect(assigns(:forms)).to match_array(user_forms)
    end

    it "does not include forms from other users" do
      expect(assigns(:forms)).not_to include(*other_forms)
    end

    it "renders the show template" do
      expect(response).to render_template(:show)
    end
  end
end
