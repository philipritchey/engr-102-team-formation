# app/controllers/form_responses_controller.rb
class FormResponsesController < ApplicationController
    before_action :set_form
  
    # GET /forms/:form_id/form_responses/new
    def new
      @form_response = @form.form_responses.new
    end
  
    # POST /forms/:form_id/form_responses
    def create
      @form_response = @form.form_responses.find_or_initialize_by(uin: form_response_params[:uin])

      if @form_response.update(form_response_params)
        redirect_to @form, notice: 'Response submitted successfully.'
      else
        flash.now[:alert] = 'There was an error submitting your response.'
        render :new
      end
    end
  
    private
  
    def set_form
      @form = Form.find(params[:form_id])
    rescue ActiveRecord::RecordNotFound
      flash[:alert] = "Form not found."
      redirect_to forms_path
    end
  
    def form_response_params
      params.require(:form_response).permit(:uin, responses: {})
    end
  end
  