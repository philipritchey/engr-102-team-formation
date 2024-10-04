require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  controller do
    def index
      render plain: "Hello, World!"
    end
  end

  let(:user) { FactoryBot.create(:user) }

  describe "#current_user" do
    context "when user is logged in" do
      before { session[:user_id] = user.id }

      it "returns the current user" do
        expect(controller.send(:current_user)).to eq(user)
      end
    end

    context "when user is not logged in" do
      it "returns nil" do
        expect(controller.send(:current_user)).to be_nil
      end
    end
  end

  describe "#logged_in?" do
    context "when user is logged in" do
      before { allow(controller).to receive(:current_user).and_return(user) }

      it "returns true" do
        expect(controller.send(:logged_in?)).to be true
      end
    end

    context "when user is not logged in" do
      before { allow(controller).to receive(:current_user).and_return(nil) }

      it "returns false" do
        expect(controller.send(:logged_in?)).to be false
      end
    end
  end

  describe "#require_login" do
    context "when user is logged in" do
      before do
        allow(controller).to receive(:logged_in?).and_return(true)
      end

      it "allows the action to proceed" do
        get :index
        expect(response).to have_http_status(:success)
        expect(response.body).to eq "Hello, World!"
      end
    end

    context "when user is not logged in" do
      before do
        allow(controller).to receive(:logged_in?).and_return(false)
      end

      it "redirects to the welcome path" do
        get :index
        expect(response).to redirect_to(welcome_path)
      end

      it "sets an alert message" do
        get :index
        expect(flash[:alert]).to eq "You must be logged in to access this section."
      end
    end
  end
end
