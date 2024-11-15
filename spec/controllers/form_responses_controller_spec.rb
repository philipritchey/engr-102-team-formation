require 'rails_helper'

RSpec.describe FormResponsesController, type: :controller do
  # Create a user and a form for testing
  let!(:user) { create(:user) }
  let(:form) { create(:form, user: user) }
  let(:student) { create(:student) }
  before do
    # Simulate a logged-in user for all tests
    request.env['rack.session'][:user_id] = user.id
    # Allow the controller to find the current user
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
  end

  describe "GET #new" do
    context "when the form and student exist" do
      before { get :new, params: { form_id: form.id, student_id: student.id } }

      it "renders the new template successfully" do
        expect(response).to be_successful
        expect(assigns(:form_response)).to be_a_new(FormResponse)
      end
    end

    context "when the form or student does not exist" do
      it "redirects to the forms index with an alert" do
        get :new, params: { form_id: 9999, student_id: 9999 } # Non-existent form ID or student ID
        expect(response).to redirect_to(forms_path)
        expect(flash[:alert]).to eq("Form or Student not found.")
      end
    end
  end
  describe "GET #new" do
    context "without a draft in session" do
      it "assigns a new form response" do
        get :new, params: { form_id: form.id, student_id: student.id }
        expect(assigns(:form_response)).to be_a_new(FormResponse)
        expect(assigns(:form_response).student).to eq(student)
      end
    end

    context "with a draft in session" do
      let(:draft_attributes) { { responses: { "question_1" => "Draft answer" } } }

      before do
        session[:draft_form_response] = draft_attributes
      end

      it "assigns a new form response with draft attributes" do
        get :new, params: { form_id: form.id, student_id: student.id }
        expect(assigns(:form_response)).to be_a_new(FormResponse)
        expect(assigns(:form_response).student).to eq(student)
        expect(assigns(:form_response).responses).to eq(draft_attributes[:responses])
      end
    end
  end

  describe "POST #create" do
    context "when the form exists with valid parameters" do
      let(:valid_attributes) { { responses: { question1: "answer1" } } }

      it "creates a new FormResponse and redirects to the form with a success notice" do
        expect {
          post :create, params: { form_id: form.id, student_id: student.id, form_response: valid_attributes }
        }.to change(FormResponse, :count).by(1)
        expect(response).to redirect_to(student_path(student)) 
      end
    end

    context "when the form exists with invalid parameters" do
      let(:invalid_attributes) { { responses: nil } }

      it "does not create a FormResponse and sets an alert" do
        expect {
          post :create, params: { form_id: form.id, student_id: student.id, form_response: invalid_attributes }
        }.not_to change(FormResponse, :count)
        expect(flash.now[:alert]).to eq("There was an error submitting your response.")
      end
    end

    context "when the form does not exist" do
      it "redirects to the forms index with an alert" do
        post :create, params: { form_id: 9999, student_id: student.id, form_response: { responses: { question1: "answer1" } } }
        expect(response).to redirect_to(forms_path)
        expect(flash[:alert]).to eq("Form or Student not found.")
      end
    end

    # New context for valid form but invalid student ID
    context "when the form exists but the student does not" do
      let(:valid_attributes) { { responses: { question1: "answer1" } } }

      it "redirects to the forms index with an alert" do
        expect {
          post :create, params: { form_id: form.id, student_id: 9999, form_response: valid_attributes }
        }.not_to change(FormResponse, :count)
        expect(response).to redirect_to(forms_path)
        expect(flash[:alert]).to eq("Form or Student not found.")
      end
    end
  end

  # New tests for destroy action
  describe "DELETE #destroy" do
    let!(:form_response) { create(:form_response, form: form, student: student) }

    it "destroys the requested form_response" do
      expect {
        delete :destroy, params: { id: form_response.id }
      }.to change(FormResponse, :count).by(-1)
    end

    it "redirects to the form_responses list" do
      delete :destroy, params: { id: form_response.id }
      expect(response).to redirect_to(form_responses_url)
    end
  end

  describe 'GET #show' do
    let(:form_response) { create(:form_response) }

    it 'assigns the requested form_response to @form_response' do
      get :show, params: { id: form_response.id }
      expect(assigns(:form_response)).to eq(form_response)
    end

    it 'renders the show template' do
      get :show, params: { id: form_response.id }
      expect(response).to render_template(:show)
    end

    it 'returns a success response' do
      get :show, params: { id: form_response.id }
      expect(response).to have_http_status(:success)
    end
  end
  describe "GET #index" do
    context "when accessing all form responses" do
      it "assigns all form responses to @form_responses" do
        form_response = create(:form_response)
        get :index
        expect(assigns(:form_responses)).to eq([ form_response ])
      end
    end

    context "when accessing form responses for a specific form" do
      it "assigns the form's responses to @form_responses" do
        form_response = create(:form_response, form: form)
        get :index, params: { form_id: form.id }
        expect(assigns(:form_responses)).to eq([ form_response ])
      end
    end

    context "when accessing form responses for a specific student" do
      it "assigns the student's responses to @form_responses" do
        form_response = create(:form_response, student: student)
        get :index, params: { student_id: student.id }
        expect(assigns(:form_responses)).to eq([ form_response ])
      end
    end
  end

  describe "GET #edit" do
    let(:form_response) { create(:form_response, form: form, student: student) }

    it "assigns the requested form_response to @form_response" do
      get :edit, params: { id: form_response.id }
      expect(assigns(:form_response)).to eq(form_response)
    end

    it "assigns the associated form to @form" do
      get :edit, params: { id: form_response.id }
      expect(assigns(:form)).to eq(form)
    end

    it "assigns the associated student to @student" do
      get :edit, params: { id: form_response.id }
      expect(assigns(:student)).to eq(student)
    end

    context "when there's a draft in the session" do
      it "assigns the draft attributes to @form_response" do
        draft_attributes = { responses: { question1: "draft answer" } }
        session[:draft_form_response] = draft_attributes
        get :edit, params: { id: form_response.id }
        expect(assigns(:form_response).responses).to eq({ "question1" => "draft answer" })
      end
    end
  end

  describe "PATCH #update" do
  let!(:form_response) { create(:form_response, form: form, student: student) }
  let(:valid_attributes) { { responses: { question1: "updated answer" } } }

  context "when submitting final response" do
    it "clears the draft from session on successful submission" do
      session[:draft_form_response] = { responses: { question1: "old draft" } }
      patch :update, params: { id: form_response.id, form_response: valid_attributes }
      expect(session[:draft_form_response]).to be_nil
    end

    it "redirects to edit path with a success notice even if the draft is null" do
      allow_any_instance_of(FormResponse).to receive(:valid?).and_return(false) # Simulate invalid form response
      
      patch :update, params: { id: form_response.id, form_response: { responses: nil }, commit: "Save as Draft" }
    
      expect(response).to redirect_to(edit_form_response_path(form_response)) # Redirects to edit path
      expect(flash[:notice]).to eq("Draft saved temporarily. It will be discarded once the session ends.") # Check success notice
    end
    
    
    
    end

    context "when submitting final response" do
      it "updates the form_response and renders success template" do
        patch :update, params: { id: form_response.id, form_response: valid_attributes }
        expect(form_response.reload.responses).to eq(valid_attributes[:responses].stringify_keys)
        expect(response).to redirect_to(student_path(student)) 
      end

      it "clears the draft from session on successful submission" do
        session[:draft_form_response] = { responses: { question1: "old draft" } }
        patch :update, params: { id: form_response.id, form_response: valid_attributes }
        expect(session[:draft_form_response]).to be_nil
      end


      it "renders edit template if update fails" do
        allow_any_instance_of(FormResponse).to receive(:update).and_return(false)
        patch :update, params: { id: form_response.id, form_response: valid_attributes }
        expect(response).to render_template(:edit)
      end
    end
  end
end 

RSpec.describe FormResponsesController, type: :controller do
  let(:user) { create(:user) }
  let(:form) { create(:form, user: user) }
  let(:student) { create(:student) }
  let(:valid_attributes) { { responses: { question1: "answer1" } } }

  before do
    # Simulate a logged-in user for all tests
    request.env['rack.session'][:user_id] = user.id
    # Allow the controller to find the current user
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
  end
  describe "PATCH #update" do
    let!(:form_response) { create(:form_response, form: form, student: student) }
    let(:valid_attributes) { { responses: { question1: "updated answer" } } }
    let(:invalid_attributes) { { responses: nil } }

    context "when saving as draft" do
      it "saves valid draft to session and redirects" do
        patch :update, params: {
          id: form_response.id,
          form_response: valid_attributes,
          commit: "Save as Draft"
        }

        expect(session[:draft_form_response]).to include(valid_attributes.stringify_keys)
        expect(response).to redirect_to(edit_form_response_path(form_response))
        expect(flash[:notice]).to eq("Draft saved temporarily. It will be discarded once the session ends.")
      end

      it "handles invalid draft" do
        allow_any_instance_of(FormResponse).to receive(:valid?).and_return(false)
      
        patch :update, params: {
          id: form_response.id,
          form_response: invalid_attributes,
          commit: "Save as Draft"
        }
      
        # Expect session[:draft_form_response] to be an empty hash
        expect(session[:draft_form_response]).to eq({})

      end
          
    end

    context "when submitting final response" do
      it "updates the form_response and renders success template" do
        patch :update, params: { id: form_response.id, form_response: valid_attributes }

        expect(form_response.reload.responses).to eq(valid_attributes[:responses].stringify_keys)
        expect(response).to redirect_to(student_path(student)) 
        expect(session[:draft_form_response]).to be_nil
      end

      it "handles update failure" do
        allow_any_instance_of(FormResponse).to receive(:update).and_return(false)

        patch :update, params: { id: form_response.id, form_response: invalid_attributes }

        expect(response).to render_template(:edit)
        expect(flash[:alert]).to eq("There was an error updating your response.")
      end
    end
  end


  describe "POST #create" do
    context "when saving as draft" do
      let(:valid_attributes) { { responses: { question1: "answer1" } } }

    it "saves the draft to session and redirects" do
      post :create, params: {
        form_id: form.id,
        student_id: student.id,
        form_response: valid_attributes,
        commit: "Save as Draft"
      }

      expect(session[:draft_form_response]).to eq(valid_attributes.deep_stringify_keys)
      expect(response).to redirect_to(new_form_student_form_response_path(form, student))
      expect(flash[:notice]).to eq("Draft saved temporarily. It will be discarded once the session ends.")
    end
  end

    context "when submitting the form" do
      it "creates a new FormResponse and renders success template" do
        expect {
          post :create, params: {
            form_id: form.id,
            student_id: student.id,
            form_response: valid_attributes
          }
        }.to change(FormResponse, :count).by(1)

        expect(response).to redirect_to(student_path(student)) 
        expect(session[:draft_form_response]).to be_nil
      end

      it "renders new template with error if save fails" do
        allow_any_instance_of(FormResponse).to receive(:save).and_return(false)

        post :create, params: {
          form_id: form.id,
          student_id: student.id,
          form_response: valid_attributes
        }

        expect(response).to render_template(:new)
        expect(flash[:alert]).to eq("There was an error submitting your response.")
      end
    end

    context "with existing draft in session" do
      let(:draft_attributes) { { responses: { question1: "draft answer" } } }

      before do
        session[:draft_form_response] = draft_attributes
      end

      it "uses draft from session when creating new form response" do
        post :create, params: {
          form_id: form.id,
          student_id: student.id,
          form_response: valid_attributes
        }

        expect(FormResponse.last.responses).to eq(valid_attributes[:responses].stringify_keys)
        expect(session[:draft_form_response]).to be_nil
      end
    end
  end
end

