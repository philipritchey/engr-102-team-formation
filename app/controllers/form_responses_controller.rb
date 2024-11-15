# app/controllers/form_responses_controller.rb
class FormResponsesController < ApplicationController
  before_action :set_form_and_student, only: [ :new, :create ]
  before_action :set_form_response, only: [ :show, :edit, :update, :destroy ]

  # GET /form_responses
  # GET /forms/:form_id/form_responses
  # GET /students/:student_id/form_responses
  def index
    if params[:form_id]
      # If we're accessing form responses for a specific form
      # Path: /forms/:form_id/form_responses
      @form = Form.find(params[:form_id])
      @form_responses = @form.form_responses
    elsif params[:student_id]
      # If we're accessing form responses for a specific student
      # Path: /students/:student_id/form_responses
      @student = Student.find(params[:student_id])
      @form_responses = @student.form_responses
    else
      # If we're accessing all form responses
      # Path: /form_responses
      @form_responses = FormResponse.all
    end
  end

  # GET /form_responses/:id
  def show
    # @form_response is set by set_form_response before_action
    @form_response = FormResponse.find(params[:id])
  end

  # GET /forms/:form_id/students/:student_id/form_responses/new
  def new
    # @form and @student are set by set_form_and_student before_action
    @form_response = @form.form_responses.new(student: @student)
    if session[:draft_form_response]
      @form_response.assign_attributes(session[:draft_form_response])
    end
  end

  # POST /forms/:form_id/students/:student_id/form_responses
  def create
    @form_response = @form.form_responses.new(form_response_params)
    @form_response.student = @student

    if params[:commit] == "Save as Draft"
      session[:draft_form_response] = form_response_params.to_h || {}
      redirect_to new_form_student_form_response_path(@form, @student), notice: "Draft saved temporarily. It will be discarded once the session ends."
    else
      if @form_response.save
        session.delete(:draft_form_response)
        redirect_to student_path(@student), notice: "Response submitted successfully." # Redirect to student's homepage
      else
        flash.now[:alert] = "There was an error submitting your response."
        render :new
      end
    end
  end





  # GET /form_responses/:id/edit
  def edit
    @form_response = FormResponse.find(params[:id]) # Fetch form response by ID from URL
    @form = @form_response.form                     # Load the associated form
    @student = @form_response.student
    if session[:draft_form_response]
      @form_response.assign_attributes(session[:draft_form_response])
    end
  end

  # PATCH/PUT /form_responses/:id
  # In app/controllers/form_responses_controller.rb

  def update
    @form_response = FormResponse.find(params[:id])
  
    if params[:commit] == "Save as Draft"
      session[:draft_form_response] = form_response_params.to_h.presence || {}
      redirect_to edit_form_response_path(@form_response), notice: "Draft saved temporarily. It will be discarded once the session ends."
    else
      if @form_response.update(form_response_params)
        session.delete(:draft_form_response)
        redirect_to student_path(@form_response.student), notice: "Response updated successfully." # Redirect to student's homepage
      else
        flash.now[:alert] = "There was an error updating your response."
        render :edit
      end
    end
  end




  # DELETE /form_responses/:id
  def destroy
    # @form_response is set by set_form_response before_action
    @form_response.destroy
    redirect_to form_responses_url, notice: "Form response was successfully destroyed."
  end

  private

  # def handle_final_update
  #   if @form_response.update(form_response_params)
  #     session.delete(:draft_form_response)
  #     render :success
  #   else
  #     flash.now[:alert] = "There was an error updating your response."
  #     render :edit
  #   end
  # end
  # Used for new and create actions
  # Sets @form and @student based on the form_id and student_id in the URL
  def set_form_and_student
    @form = Form.find(params[:form_id])
    @student = Student.find(params[:student_id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "Form or Student not found."
    redirect_to forms_path
  end

  # Used for show, edit, update, and destroy actions
  # Sets @form_response based on the id in the URL
  def set_form_response
    @form_response = FormResponse.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "Form response not found."
    redirect_to form_responses_path
  end

  # Defines allowed parameters for form responses
  # Only allows the 'responses' hash to be mass-assigned
  def form_response_params
    params.require(:form_response).permit(responses: {})
  end
end
