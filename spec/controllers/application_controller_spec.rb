# This file contains RSpec tests for the ApplicationController
# It focuses on testing authentication-related methods like current_user, logged_in?, and require_login
# These tests ensure that user authentication is working correctly across the application

require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  # Define a dummy controller for testing purposes
  controller do
    def index
      render plain: "Hello, World!"
    end
  end

  # Create a user using FactoryBot for our tests
  let(:user) { FactoryBot.create(:user) }

  describe "#current_user" do
    context "when user is logged in" do
      # Simulate a logged-in user by setting the user_id in the session
      before { session[:user_id] = user.id }

      it "returns the current user" do
        # Use 'send' to call the private method 'current_user'
        expect(controller.send(:current_user)).to eq(user)
      end
    end

    context "when user is not logged in" do
      it "returns nil" do
        # When no user is logged in, current_user should return nil
        expect(controller.send(:current_user)).to be_nil
      end
    end
  end

  describe "#logged_in?" do
    context "when user is logged in" do
      # Mock the current_user method to return a user
      before { allow(controller).to receive(:current_user).and_return(user) }

      it "returns true" do
        # logged_in? should return true when there's a current user
        expect(controller.send(:logged_in?)).to be true
      end
    end

    context "when user is not logged in" do
      # Mock the current_user method to return nil
      before { allow(controller).to receive(:current_user).and_return(nil) }

      it "returns false" do
        # logged_in? should return false when there's no current user
        expect(controller.send(:logged_in?)).to be false
      end
    end
  end

  describe "#require_login" do
    context "when user is logged in" do
      before do
        # Mock logged_in? to return true
        allow(controller).to receive(:logged_in?).and_return(true)
      end

      it "allows the action to proceed" do
        get :index
        # Check that the response is successful
        expect(response).to have_http_status(:success)
        # Check that the action was actually executed
        expect(response.body).to eq "Hello, World!"
      end
    end

    context "when user is not logged in" do
      before do
        # Mock logged_in? to return false
        allow(controller).to receive(:logged_in?).and_return(false)
      end

      it "redirects to the welcome path" do
        get :index
        # Check that the user is redirected to the welcome path
        expect(response).to redirect_to(welcome_path)
      end

      it "sets an alert message" do
        get :index
        # Check that the correct alert message is set
        expect(flash[:alert]).to eq "You must be logged in to access this section."
      end
    end
  end
end
