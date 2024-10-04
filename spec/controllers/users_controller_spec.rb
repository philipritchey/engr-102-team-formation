# This file contains RSpec tests for the UsersController
# It focuses on testing the show action, which displays a user's profile and associated forms

require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  describe "GET #show" do
    # Create a user for testing
    let(:user) { create(:user) }

    # Create 3 forms associated with the user
    let!(:user_forms) { create_list(:form, 3, user: user) }

    # Create 2 forms not associated with the user
    let!(:other_forms) { create_list(:form, 2) }

    before do
      # Simulate user login by mocking the current_user method
      # This allows us to test as if the user is logged in
      allow(controller).to receive(:current_user).and_return(user)

      # Perform a GET request to the show action with the user's id
      get :show, params: { id: user.id }
    end

    it "returns a success response" do
      # Check if the response is successful (HTTP status 200-299)
      expect(response).to be_successful
    end

    it "assigns @forms with the current user's forms" do
      # Verify that @forms contains only the forms associated with the user
      # match_array is used because the order of the forms doesn't matter
      expect(assigns(:forms)).to match_array(user_forms)
    end

    it "does not include forms from other users" do
      # Ensure that @forms does not contain any forms not associated with the user
      # The splat operator (*) is used to pass the array elements as individual arguments
      expect(assigns(:forms)).not_to include(*other_forms)
    end

    it "renders the show template" do
      # Check if the response renders the 'show' template
      expect(response).to render_template(:show)
    end
  end
end
