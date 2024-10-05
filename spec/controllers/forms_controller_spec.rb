# This file contains RSpec tests for the FormsController
# It covers all CRUD operations (index, show, new, create, edit, update, destroy)
# These tests ensure that forms can be properly managed by authenticated users

require 'rails_helper'

RSpec.describe FormsController, type: :controller do
  # Create a user and a form for testing
  let!(:user) { create(:user) }
  let(:form) { create(:form, user: user) }

  before do
    # Simulate a logged-in user for all tests
    session[:user_id] = user.id
    # Allow the controller to find the current user
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
  end


  describe "GET #upload" do
    it "returns a success response" do
      get :upload
      expect(response).to be_successful
    end
  end

  describe "POST #validate_upload" do
    context "when no file is uploaded" do
      it "sets a flash alert and redirects to the user page" do
        post :validate_upload, params: { file: nil }
        expect(flash[:alert]).to eq("Please upload a file.")
        expect(response).to redirect_to(user_path(user))
      end
    end

    context "when file is uploaded" do
      let(:file) { fixture_file_upload('valid_file.csv', 'text/csv') }

      it "successfully validates the file and creates users" do
        expect {
          post :validate_upload, params: { file: file }
        }.to change(User, :count).by(1)

        expect(flash[:notice]).to eq("All validations passed.")
      end

      context "when the first row is empty" do
        let(:file) { fixture_file_upload('empty_header.csv', 'text/csv') }

        it "sets a flash alert for empty first row and redirects" do
          post :validate_upload, params: { file: file }
          expect(flash[:alert]).to eq("The first row is empty. Please provide column names.")
        end
      end

      context "when required columns are missing" do
        let(:file) { fixture_file_upload('missing_columns.csv', 'text/csv') }

        it "sets a flash alert for missing columns and redirects" do
          post :validate_upload, params: { file: file }
          expect(flash[:alert]).to eq("Missing required columns. Ensure 'Name', 'UIN', and 'Email ID' are present.")
        end
      end

      context "when UIN is invalid" do
        let(:file) { fixture_file_upload('invalid_uin.csv', 'text/csv') }

        it "sets a flash alert for invalid UIN and redirects" do
          post :validate_upload, params: { file: file }
          expect(flash[:alert]).to eq("Invalid UIN in 'UIN' column for row 2. It must be a 9-digit number.")
          expect(response).to redirect_to(user_path(user))
        end
      end

      context "when email is missing" do
        let(:file) { fixture_file_upload('missing_email.csv', 'text/csv') }

        it "sets a flash alert for missing email and redirects" do
          post :validate_upload, params: { file: file }
          expect(flash[:alert]).to eq("Missing value in 'Email ID' column for row 2.")
          expect(response).to redirect_to(user_path(user))
        end
      end

      context "when email is invalid" do
        let(:file) { fixture_file_upload('invalid_email.csv', 'text/csv') }

        it "sets a flash alert for invalid email and redirects" do
          post :validate_upload, params: { file: file }
          expect(flash[:alert]).to eq("Invalid email in 'Email ID' column for row 2.")
          expect(response).to redirect_to(user_path(user))
        end
      end

      context "when a row has missing or invalid data" do
        let(:file) { fixture_file_upload('missing_name.csv', 'text/csv') }

        it "sets a flash alert for missing name and redirects" do
          post :validate_upload, params: { file: file }
          expect(flash[:alert]).to eq("Missing value in 'Name' column for row 2.")
        end
      end
    end
  end

  describe "GET #index" do
    it "returns a success response" do
      # Test if the index action returns a successful response
      get :index
      expect(response).to be_successful
    end

    it "assigns @forms" do
      form # Ensure the form is created
      # Test if the index action assigns the correct forms to @forms
      get :index
      expect(assigns(:forms)).to eq([ form ])
    end
  end

  describe "GET #show" do
    it "returns a success response" do
      # Test if the show action returns a successful response
      get :show, params: { id: form.id }
      expect(response).to be_successful
    end

    it "assigns the requested form to @form" do
      # Test if the show action assigns the correct form to @form
      get :show, params: { id: form.id }
      expect(assigns(:form)).to eq(form)
    end
  end

  describe "GET #new" do
    it "returns a success response" do
      # Test if the new action returns a successful response
      get :new
      expect(response).to be_successful
    end

    it "assigns a new Form to @form" do
      # Test if the new action assigns a new Form object to @form
      get :new
      expect(assigns(:form)).to be_a_new(Form)
    end
  end

  describe "GET #edit" do
    it "returns a success response" do
      # Test if the edit action returns a successful response
      get :edit, params: { id: form.id }
      expect(response).to be_successful
    end

    it "assigns the requested form to @form" do
      # Test if the edit action assigns the correct form to @form
      get :edit, params: { id: form.id }
      expect(assigns(:form)).to eq(form)
    end

    it "builds a new form attribute" do
      # Test if the edit action builds a new attribute for the form
      get :edit, params: { id: form.id }
      expect(assigns(:attribute)).to be_a_new(Attribute)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      let(:valid_attributes) { attributes_for(:form) }

      it "creates a new Form" do
        # Test if a new Form is created when valid attributes are provided
        expect {
          post :create, params: { form: valid_attributes }
        }.to change(Form, :count).by(1)
      end

      it "redirects to the edit page of the created form" do
        # Test if the user is redirected to the edit page after form creation
        post :create, params: { form: valid_attributes }
        expect(response).to redirect_to(edit_form_path(Form.last))
      end
    end

    context "with invalid params" do
      let(:invalid_attributes) { attributes_for(:form, name: nil) }

      it "does not create a new Form" do
        # Test if a new Form is not created when invalid attributes are provided
        expect {
          post :create, params: { form: invalid_attributes }
        }.to_not change(Form, :count)
      end

      it "renders the 'new' template" do
        # Test if the new template is rendered when form creation fails
        post :create, params: { form: invalid_attributes }
        expect(response).to render_template("new")
      end
    end

    context "when form params are not nested" do
      let(:valid_attributes) { { name: "Non-nested Form", description: "Description" } }

      it "creates a new Form with non-nested params" do
        # Test if a new Form is created when valid non-nested attributes are provided
        expect {
          post :create, params: valid_attributes
        }.to change(Form, :count).by(1)
      end

      it "redirects to the edit page of the created form" do
        # Test if the user is redirected to the edit page after form creation with non-nested params
        post :create, params: valid_attributes
        expect(response).to redirect_to(edit_form_path(Form.last))
      end
    end

    context "when all form params are missing" do
      it "does not create a new Form" do
        # Test if a new Form is not created when no parameters are provided
        expect {
          post :create, params: {}
        }.not_to change(Form, :count)
      end

      it "renders the 'new' template" do
        # Test if the new template is rendered when no parameters are provided
        post :create, params: {}
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) { { name: "Updated Form Name" } }

      it "updates the requested form" do
        # Test if the form is updated with valid attributes
        put :update, params: { id: form.id, form: new_attributes }
        form.reload
        expect(form.name).to eq("Updated Form Name")
      end

      it "redirects to the form" do
        # Test if the user is redirected to the form page after successful update
        put :update, params: { id: form.id, form: new_attributes }
        expect(response).to redirect_to(form)
      end
    end

    context "with invalid params" do
      let(:invalid_attributes) { { name: nil } }

      it "does not update the form" do
        # Test if the form is not updated with invalid attributes
        put :update, params: { id: form.id, form: invalid_attributes }
        form.reload
        expect(form.name).not_to be_nil
      end

      it "renders the 'edit' template" do
        # Test if the edit template is rendered when form update fails
        put :update, params: { id: form.id, form: invalid_attributes }
        expect(response).to render_template("edit")
      end
    end

    context "when form params are not nested" do
      let(:new_attributes) { { name: "Updated Non-nested Form", description: "New Description" } }

      it "updates the requested form with non-nested params" do
        # Test if the form is updated with valid non-nested attributes
        put :update, params: { id: form.id }.merge(new_attributes)
        form.reload
        expect(form.name).to eq("Updated Non-nested Form")
        expect(form.description).to eq("New Description")
      end

      it "redirects to the form" do
        # Test if the user is redirected to the form page after successful update with non-nested params
        put :update, params: { id: form.id }.merge(new_attributes)
        expect(response).to redirect_to(form)
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested form" do
      # Test if the form is destroyed when the delete action is called
      form_to_delete = create(:form, user: user)
      expect {
        delete :destroy, params: { id: form_to_delete.id }
      }.to change(Form, :count).by(-1)
    end

    it "redirects to the user's show page" do
      # Test if the user is redirected to their show page after form deletion
      delete :destroy, params: { id: form.id }
      expect(response).to redirect_to(user_path(user))
    end
  end

  describe "GET #upload" do
    it "returns a success response" do
      # Test if the upload action returns a successful response
      get :upload
      expect(response).to be_successful
    end
  end

  describe 'PATCH #update_deadline' do
    context 'with valid deadline' do
      let(:new_deadline) { { deadline: (Time.current + 3.days) } }

      it 'updates the form deadline' do
        patch :update_deadline, params: { id: form.id, form: new_deadline }
        form.reload
        expect(form.deadline.to_i).to eq(new_deadline[:deadline].to_i)
      end

      it 'redirects to the index page with a success message' do
        patch :update_deadline, params: { id: form.id, form: new_deadline }
        expect(response).to redirect_to(user_path(user))
        expect(flash[:notice]).to eq('Deadline was successfully updated.')
      end
    end

    context 'with invalid deadline' do
      let(:invalid_deadline) { { deadline: (Time.current - 1.day) } }

      it 'does not update the form deadline' do
        patch :update_deadline, params: { id: form.id, form: invalid_deadline }
        form.reload
        expect(form.deadline).not_to eq(invalid_deadline[:deadline])
      end

      it 'redirects to the index page with an error message' do
        patch :update_deadline, params: { id: form.id, form: invalid_deadline }
        expect(response).to redirect_to(user_path(user))
        expect(flash[:alert]).to eq('Failed to update the deadline.')
      end
    end
  end
end
