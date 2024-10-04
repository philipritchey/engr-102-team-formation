require 'rails_helper'

RSpec.describe FormsController, type: :controller do
  let!(:user) { create(:user) }
  let(:form) { create(:form, user: user) }

  before do
    # Simulate a logged-in user
    session[:user_id] = user.id
    # Allow the controller to find the current user
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
  end

  describe "GET #index" do
    it "returns a success response" do
      get :index
      expect(response).to be_successful
    end

    it "assigns @forms" do
      form # Ensure the form is created
      get :index
      expect(assigns(:forms)).to eq([ form ])
    end
  end

  describe "GET #show" do
    it "returns a success response" do
      get :show, params: { id: form.id }
      expect(response).to be_successful
    end

    it "assigns the requested form to @form" do
      get :show, params: { id: form.id }
      expect(assigns(:form)).to eq(form)
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
    it "returns a success response" do
      get :edit, params: { id: form.id }
      expect(response).to be_successful
    end

    it "assigns the requested form to @form" do
      get :edit, params: { id: form.id }
      expect(assigns(:form)).to eq(form)
    end

    it "builds a new form attribute" do
      get :edit, params: { id: form.id }
      expect(assigns(:attribute)).to be_a_new(Attribute)
    end
  end

  describe "POST #create" do
    context "with valid params" do
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

    context "with invalid params" do
      let(:invalid_attributes) { attributes_for(:form, name: nil) }

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

    context "when form params are not nested" do
      let(:valid_attributes) { { name: "Non-nested Form", description: "Description" } }

      it "creates a new Form with non-nested params" do
        expect {
          post :create, params: valid_attributes
        }.to change(Form, :count).by(1)
      end

      it "redirects to the edit page of the created form" do
        post :create, params: valid_attributes
        expect(response).to redirect_to(edit_form_path(Form.last))
      end
    end

    context "when all form params are missing" do
      it "does not create a new Form" do
        expect {
          post :create, params: {}
        }.not_to change(Form, :count)
      end

      it "renders the 'new' template" do
        post :create, params: {}
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) { { name: "Updated Form Name" } }

      it "updates the requested form" do
        put :update, params: { id: form.id, form: new_attributes }
        form.reload
        expect(form.name).to eq("Updated Form Name")
      end

      it "redirects to the form" do
        put :update, params: { id: form.id, form: new_attributes }
        expect(response).to redirect_to(form)
      end
    end

    context "with invalid params" do
      let(:invalid_attributes) { { name: nil } }

      it "does not update the form" do
        put :update, params: { id: form.id, form: invalid_attributes }
        form.reload
        expect(form.name).not_to be_nil
      end

      it "renders the 'edit' template" do
        put :update, params: { id: form.id, form: invalid_attributes }
        expect(response).to render_template("edit")
      end
    end

    context "when form params are not nested" do
      let(:new_attributes) { { name: "Updated Non-nested Form", description: "New Description" } }

      it "updates the requested form with non-nested params" do
        put :update, params: { id: form.id }.merge(new_attributes)
        form.reload
        expect(form.name).to eq("Updated Non-nested Form")
        expect(form.description).to eq("New Description")
      end

      it "redirects to the form" do
        put :update, params: { id: form.id }.merge(new_attributes)
        expect(response).to redirect_to(form)
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested form" do
      form_to_delete = create(:form, user: user)
      expect {
        delete :destroy, params: { id: form_to_delete.id }
      }.to change(Form, :count).by(-1)
    end

    it "redirects to the user's show page" do
      delete :destroy, params: { id: form.id }
      expect(response).to redirect_to(user_path(user))
    end
  end

  describe "GET #upload" do
    it "returns a success response" do
      get :upload
      expect(response).to be_successful
    end
  end
end
