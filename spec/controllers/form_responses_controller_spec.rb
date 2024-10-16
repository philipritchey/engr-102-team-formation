require 'rails_helper'

RSpec.describe FormResponsesController, type: :controller do
  # Create a user and a form for testing
  let!(:user) { create(:user) }
  let(:form) { create(:form, user: user) }

  before do
    # Simulate a logged-in user for all tests
    request.env['rack.session'][:user_id] = user.id
    # Allow the controller to find the current user
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
  end

  describe "GET #new" do
    context "when the form exists" do
      before { get :new, params: { form_id: form.id } }

      it "renders the new template successfully" do
        expect(response).to be_successful
        expect(assigns(:form_response)).to be_a_new(FormResponse)
      end
    end

    context "when the form does not exist" do
      it "redirects to the forms index with an alert" do
        get :new, params: { form_id: 999 } # Non-existent form ID
        expect(response).to redirect_to(forms_path)
        expect(flash[:alert]).to eq("Form not found.")
      end
    end
  end

  describe "POST #create" do
    context "when the form exists with valid parameters" do
      let(:valid_attributes) { { uin: "12345", responses: { question1: "answer1" } } }

      it "creates a new FormResponse and redirects to the form with a success notice" do
        expect {
          post :create, params: { form_id: form.id, form_response: valid_attributes }
        }.to change(FormResponse, :count).by(1)
        expect(response).to render_template(:success)
      end
    end

    context "when the form exists with invalid parameters" do
      let(:invalid_attributes) { { uin: nil } }

      it "does not create a FormResponse and renders the new template with an alert" do
        expect {
          post :create, params: { form_id: form.id, form_response: invalid_attributes }
        }.not_to change(FormResponse, :count)
        expect(response).to render_template(:new)
        expect(flash.now[:alert]).to eq("There was an error submitting your response.")
      end
    end

    context "when the form does not exist" do
      it "redirects to the forms index with an alert" do
        post :create, params: { form_id: 999, form_response: { uin: "12345" } }
        expect(response).to redirect_to(forms_path)
        expect(flash[:alert]).to eq("Form not found.")
      end
    end
  end
end
