require 'rails_helper'

RSpec.describe FormsController, type: :controller do
  describe "GET #index" do
    let!(:form1) { create(:form, name: "Form 1", description: "Description 1") }
    let!(:form2) { create(:form, name: "Form 2", description: "Description 2") }

    it "returns a success response" do
      get :index
      expect(response).to be_successful
    end

    it "assigns all forms to @forms" do
      get :index
      expect(assigns(:forms)).to match_array([ form1, form2 ])
    end
  end

  describe "GET #new" do
    it "returns a success response" do
      get :new
      expect(response).to be_successful
    end

    it "assigns a new Form to @form" do
      get :new
      expect(assigns(:form)).to be_a_new(Form)
    end
  end

  describe "GET #edit" do
    let!(:form) { create(:form) }

    it "returns a success response" do
      get :edit, params: { id: form.to_param }
      expect(response).to be_successful
    end

    it "assigns the requested form to @form" do
      get :edit, params: { id: form.to_param }
      expect(assigns(:form)).to eq(form)
    end

    it "builds a new form attribute" do
      get :edit, params: { id: form.to_param }
      expect(assigns(:attribute)).to be_a_new(Attribute)
    end
  end

  describe "POST #create" do
    context "with valid parameters" do
      let(:valid_attributes) { attributes_for(:form) }

      it "creates a new Form" do
        expect {
          post :create, params: { form: valid_attributes }
        }.to change(Form, :count).by(1)
      end

      it "redirects to the edit page of the created form" do
        post :create, params: { form: valid_attributes }
        expect(response).to redirect_to(edit_form_path(Form.last))
      end
    end

    context "with invalid parameters" do
      let(:invalid_attributes) { attributes_for(:form, name: "") }

      it "does not create a new Form" do
        expect {
          post :create, params: { form: invalid_attributes }
        }.to_not change(Form, :count)
      end

      it "renders the 'new' template" do
        post :create, params: { form: invalid_attributes }
        expect(response).to render_template("new")
      end
    end
  end

  describe "PATCH #update" do
    let!(:form) { create(:form) }

    context "with valid parameters" do
      let(:new_attributes) { { name: "Updated Form", description: "Updated description" } }

      it "updates the requested form" do
        patch :update, params: { id: form.to_param, form: new_attributes }
        form.reload
        expect(form.name).to eq("Updated Form")
        expect(form.description).to eq("Updated description")
      end

      it "redirects to the form" do
        patch :update, params: { id: form.to_param, form: new_attributes }
        expect(response).to redirect_to(form)
      end

      it "sets a success notice" do
        patch :update, params: { id: form.to_param, form: new_attributes }
        expect(flash[:notice]).to eq("Form was successfully updated.")
      end
    end

    context "with invalid parameters" do
      let(:invalid_attributes) { { name: "" } }

      it "does not update the form" do
        patch :update, params: { id: form.to_param, form: invalid_attributes }
        form.reload
        expect(form.name).not_to eq("")
      end

      it "renders the 'edit' template" do
        patch :update, params: { id: form.to_param, form: invalid_attributes }
        expect(response).to render_template("edit")
      end

      it "returns unprocessable_entity status" do
        patch :update, params: { id: form.to_param, form: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "with JSON request" do
      let(:new_attributes) { { name: "Updated Form", description: "Updated description" } }

      it "updates the requested form and returns JSON response" do
        patch :update, params: { id: form.to_param, form: new_attributes }, format: :json
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response["name"]).to eq("Updated Form")
        expect(json_response["description"]).to eq("Updated description")
      end

      it "returns errors as JSON when update fails" do
        patch :update, params: { id: form.to_param, form: { name: "" } }, format: :json
        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response).to have_key("errors")
        expect(json_response["errors"]).to have_key("name")
      end
    end
  end

  describe "DELETE #destroy" do
    let!(:form) { create(:form) }

    it "destroys the requested form" do
      expect {
        delete :destroy, params: { id: form.to_param }
      }.to change(Form, :count).by(-1)
    end

    it "redirects to the forms list" do
      delete :destroy, params: { id: form.to_param }
      expect(response).to redirect_to(forms_path)
    end

    it "sets a success notice" do
      delete :destroy, params: { id: form.to_param }
      expect(flash[:notice]).to eq("Form was successfully destroyed.")
    end

    it "returns no content for JSON request" do
      delete :destroy, params: { id: form.to_param }, format: :json
      expect(response).to have_http_status(:no_content)
    end
  end
end
