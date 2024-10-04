require 'rails_helper'

RSpec.describe AttributesController, type: :controller do
  let(:user) { create(:user) }
  let(:form) { create(:form, user: user) }
  let(:valid_attributes) { attributes_for(:attribute) }
  let(:invalid_attributes) { attributes_for(:attribute, name: nil) }

  before do
    # Simulate a logged-in user
    session[:user_id] = user.id
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Attribute" do
        expect {
          post :create, params: { form_id: form.id, attribute: valid_attributes }
        }.to change(Attribute, :count).by(1)
      end

      it "redirects to the form edit page" do
        post :create, params: { form_id: form.id, attribute: valid_attributes }
        expect(response).to redirect_to(edit_form_path(form))
      end

      it "sets a success notice" do
        post :create, params: { form_id: form.id, attribute: valid_attributes }
        expect(flash[:notice]).to eq("Attribute was successfully added.")
      end
    end

    context "with invalid params" do
      it "does not create a new Attribute" do
        expect {
          post :create, params: { form_id: form.id, attribute: invalid_attributes }
        }.to_not change(Attribute, :count)
      end

      it "redirects to the form edit page" do
        post :create, params: { form_id: form.id, attribute: invalid_attributes }
        expect(response).to redirect_to(edit_form_path(form))
      end

      it "sets an alert message" do
        post :create, params: { form_id: form.id, attribute: invalid_attributes }
        expect(flash[:alert]).to eq("Failed to add attribute.")
      end
    end
  end

  describe "DELETE #destroy" do
    let!(:attribute) { create(:attribute, form: form) }

    it "destroys the requested attribute" do
      expect {
        delete :destroy, params: { form_id: form.id, id: attribute.id }
      }.to change(Attribute, :count).by(-1)
    end

    it "redirects to the form edit page" do
      delete :destroy, params: { form_id: form.id, id: attribute.id }
      expect(response).to redirect_to(edit_form_path(form))
    end

    it "sets a success notice" do
      delete :destroy, params: { form_id: form.id, id: attribute.id }
      expect(flash[:notice]).to eq("Attribute was successfully removed.")
    end

    context "when attribute doesn't exist" do
      it "redirects to the form edit page" do
        delete :destroy, params: { form_id: form.id, id: 9999 }
        expect(response).to redirect_to(edit_form_path(form))
      end

      it "sets an alert message" do
        delete :destroy, params: { form_id: form.id, id: 9999 }
        expect(flash[:alert]).to eq("Attribute not found")
      end
    end

    context "when attribute fails to be destroyed" do
      before do
        allow_any_instance_of(Attribute).to receive(:destroy).and_return(false)
      end

      it "redirects to the form edit page with an alert" do
        delete :destroy, params: { form_id: form.id, id: attribute.id }
        expect(response).to redirect_to(edit_form_path(form))
        expect(flash[:alert]).to eq("Failed to remove attribute.")
      end
    end
  end

  describe "Error handling" do
    context "when form doesn't exist" do
      it "redirects to forms index" do
        post :create, params: { form_id: 9999, attribute: valid_attributes }
        expect(response).to redirect_to(forms_path)
      end

      it "sets an alert message" do
        post :create, params: { form_id: 9999, attribute: valid_attributes }
        expect(flash[:alert]).to eq("Form not found")
      end
    end
  end
end
