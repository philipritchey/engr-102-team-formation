require 'rails_helper'

RSpec.describe AttributesController, type: :controller do
  let(:form) { create(:form) }

  describe "POST #create" do
    context "with valid attributes" do
      let(:valid_attributes) { attributes_for(:attribute) }

      it "creates a new Attribute" do
        expect {
          post :create, params: { form_id: form.id, attribute: valid_attributes }
        }.to change(Attribute, :count).by(1)
      end

      it "redirects to the form edit page with a notice" do
        post :create, params: { form_id: form.id, attribute: valid_attributes }
        expect(response).to redirect_to(edit_form_path(form))
        expect(flash[:notice]).to eq("Attribute was successfully added.")
      end

      context "for scale type" do
        let(:valid_scale_attributes) { attributes_for(:attribute, field_type: 'scale', min_value: 1, max_value: 10) }

        it "creates a new scale Attribute" do
          expect {
            post :create, params: { form_id: form.id, attribute: valid_scale_attributes }
          }.to change(Attribute, :count).by(1)
        end
      end

      context "for mcq type" do
        let(:valid_mcq_attributes) { attributes_for(:attribute, field_type: 'mcq', options: "Option 1, Option 2") }

        it "creates a new mcq Attribute" do
          expect {
            post :create, params: { form_id: form.id, attribute: valid_mcq_attributes }
          }.to change(Attribute, :count).by(1)
        end
      end
    end

    context "with invalid attributes" do
      let(:invalid_attributes) { attributes_for(:attribute, name: nil) }

      it "does not create a new Attribute" do
        expect {
          post :create, params: { form_id: form.id, attribute: invalid_attributes }
        }.not_to change(Attribute, :count)
      end

      it "redirects to the form edit page with an alert" do
        post :create, params: { form_id: form.id, attribute: invalid_attributes }
        expect(response).to redirect_to(edit_form_path(form))
        expect(flash[:alert]).to eq("Failed to add attribute.")
      end

      context "for scale type" do
        let(:invalid_scale_attributes) { attributes_for(:attribute, field_type: 'scale', min_value: 10, max_value: 1) }

        it "does not create a new Attribute with invalid scale range" do
          expect {
            post :create, params: { form_id: form.id, attribute: invalid_scale_attributes }
          }.not_to change(Attribute, :count)
        end

        it "redirects to the form edit page with an alert for invalid scale" do
          post :create, params: { form_id: form.id, attribute: invalid_scale_attributes }
          expect(response).to redirect_to(edit_form_path(form))
          expect(flash[:alert]).to eq("Failed to add attribute.")
        end
      end

      context "for mcq type" do
        let(:invalid_mcq_attributes) { attributes_for(:attribute, field_type: 'mcq', options: "Single Option") }

        it "does not create a new Attribute with insufficient mcq options" do
          expect {
            post :create, params: { form_id: form.id, attribute: invalid_mcq_attributes }
          }.not_to change(Attribute, :count)
        end

        it "redirects to the form edit page with an alert for invalid mcq options" do
          post :create, params: { form_id: form.id, attribute: invalid_mcq_attributes }
          expect(response).to redirect_to(edit_form_path(form))
          expect(flash[:alert]).to eq("Failed to add attribute.")
        end
      end
    end
  end

  describe "DELETE #destroy" do
    let!(:attribute) { create(:attribute, form: form) }

    context "when attribute is successfully destroyed" do
      it "destroys the requested attribute" do
        expect {
          delete :destroy, params: { form_id: form.id, id: attribute.id }
        }.to change(Attribute, :count).by(-1)
      end

      it "redirects to the form edit page with a notice" do
        delete :destroy, params: { form_id: form.id, id: attribute.id }
        expect(response).to redirect_to(edit_form_path(form))
        expect(flash[:notice]).to eq("Attribute was successfully removed.")
      end
    end

    context "when attribute fails to be destroyed" do
      before do
        allow_any_instance_of(Attribute).to receive(:destroy).and_return(false)
      end

      it "does not destroy the attribute" do
        expect {
          delete :destroy, params: { form_id: form.id, id: attribute.id }
        }.not_to change(Attribute, :count)
      end

      it "redirects to the form edit page with an alert" do
        delete :destroy, params: { form_id: form.id, id: attribute.id }
        expect(response).to redirect_to(edit_form_path(form))
        expect(flash[:alert]).to eq("Failed to remove attribute.")
      end
    end
  end

  describe "Error handling" do
    context "when form is not found" do
      it "redirects to forms path with an alert" do
        post :create, params: { form_id: 'nonexistent', attribute: attributes_for(:attribute) }
        expect(response).to redirect_to(forms_path)
        expect(flash[:alert]).to eq("Form not found")
      end
    end

    context "when attribute is not found" do
      it "redirects to edit form path with an alert" do
        delete :destroy, params: { form_id: form.id, id: 'nonexistent' }
        expect(response).to redirect_to(edit_form_path(form))
        expect(flash[:alert]).to eq("Attribute not found")
      end
    end
  end
end
