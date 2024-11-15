# This controller handles CRUD operations for forms
# It also includes functionality for uploading and validating user data

class FormsController < ApplicationController
  include FormsHelper
  include FormPublishing
  include FormDeadlineManagement
  include FormUploading
  include TeamCalculation
  include TeamGenderBalance
  include TeamEthnicityBalance
  include TeamSkillBalance
  include PopulateTeamsBasedOnGender
  include GenerateTeams
  include FormDeadlineManagement
  include ExportTeams
  require "roo"

  # Set @form instance variable for show, edit, update, and destroy actions
  before_action :set_form, only: %i[ show edit update destroy update_deadline publish close generate_teams view_teams]
  before_action :set_form, only: %i[ show edit update destroy update_deadline publish close generate_teams view_teams]

  # GET /forms
  def index
    # TODO: Implement form listing logic
    @forms = Form.all  # Currently fetches all forms, might need pagination or scoping
  end

  # GET /forms/1
  # Displays a specific form
  def show
    # @form is already set by before_action
  end

  # GET /forms/new
  # Displays the form for creating a new form
  def new
    # Initialize a new Form object for the form builder
    @form = Form.new
  end

  # GET /forms/1/edit
  # Displays the form for editing an existing form
  def edit
    # Build a new attribute for the form
    # This allows adding new attributes in the edit view
    @attribute = @form.form_attributes.build
  end

  # POST /forms
  # Creates a new form
  def create
    # Build a new form associated with the current user
    @form = current_user.forms.build(form_params)

    if @form.save
      # Redirect to edit page to add attributes after successful creation
      redirect_to edit_form_path(@form), notice: "Form was successfully created. You can now add attributes."
    else
      # If save fails, set error message and re-render the new form
      flash.now[:alert] = @form.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /forms/1
  # Updates an existing form
  # In FormsController

  def update
    # Allow params with or without 'form' key
    update_params = params[:form] || params

    if @form.update(update_params.permit(:name, :description, :deadline))
      # If update succeeds, set success message and redirect to the form
      flash[:notice] = "Form was successfully updated."
      redirect_to @form
    else
      # If update fails, rebuild the attribute and re-render the edit form
      @attribute = @form.form_attributes.build
      render :edit, status: :unprocessable_entity
    end
  end
  def update_deadline
    new_deadline = params[:deadline]
  
    return render_error("No deadline provided.") if new_deadline.blank?
  
    parsed_deadline = Time.zone.parse(new_deadline)
  
    return render_error("The deadline cannot be in the past.") if parsed_deadline < DateTime.now
  
    if @form.update(deadline: parsed_deadline)
      render_success
    else
      render_error("Failed to update deadline.")
    end
  end
  
  

  
  

  # GET /forms/#id/preview
  def preview
    @form = Form.find(params[:id])
    render partial: "preview"
  end

  # GET /forms/#id/duplicate
  # opens new /forms/#new_id/edit
  def duplicate
    original_form = Form.find(params[:id])
    result = Forms::DuplicationService.call(original_form)

    if result.success?
      redirect_to edit_form_path(result.form), notice: "Form was successfully duplicated."
    else
      redirect_to edit_form_path(original_form),
                  alert: "Failed to duplicate the form. #{result.errors&.join(', ')}"
    end
  end

  # DELETE /forms/1
  # Deletes a specific form
  def destroy
    @form.destroy!

    respond_to do |format|
      # Redirect to user's show page after successful deletion
      format.html { redirect_to user_path(current_user), status: :see_other, notice: "Form was successfully destroyed." }
      format.json { head :no_content }
    end
  end
  # GET /forms/1/view_teams
  def view_teams
    @teams = @form.teams
  end
  private

  
  def render_error(message)
    render json: { error: message }, status: :unprocessable_entity
  end
  
  def render_success
    render json: { message: "Deadline updated successfully.", new_deadline: @form.deadline.strftime("%Y-%m-%dT%H:%M") }, status: :ok
  end
    # Sets @form instance variable based on the id parameter
    # Only finds forms belonging to the current user for security
    def set_form
      @form = current_user.forms.find(params[:id])
    end

    # Define allowed parameters for form creation and update
    # This is a security measure to prevent mass assignment vulnerabilities
    def form_params
      params.require(:form).permit(:name, :description, :deadline)
    rescue ActionController::ParameterMissing
      # If :form key is missing, permit name and description directly from params
      # This allows for more flexible parameter handling
      params.permit(:name, :description, :deadline)
    end

    def optimize_teams_based_on_ethnicity(team_distribution)
      # Dummy function: Just return the input for now
      team_distribution
    end

    def distribute_remaining_students(team_distribution)
      # Dummy function: Distribute remaining students randomly
      team_distribution
    end

    def optimize_team_by_swaps(team_distribution)
      # Dummy function: Just return the input for now
      team_distribution
    end
    def format_team_members(team_members_ids)
      return [] if team_members_ids.blank?

      students = Student.where(id: team_members_ids)
      formatted_members = students.map do |student|
        {
          id: student.id,
          name: student.name,
          uin: student.uin,
          email: student.email
        }
      end

      formatted_members.presence || []
    end

    # Helper method to calculate the weighted average score for a student
    def calculate_weighted_average(response)
      excluded_attrs = [ "gender", "ethnicity" ]
      attributes = response.form.form_attributes.reject { |attr| excluded_attrs.include?(attr.name.downcase) }

      total_score = 0.0
      total_weight = 0.0

      attributes.each do |attribute|
        weightage = attribute.weightage
        student_response = response.responses[attribute.id.to_s]  # Convert id to string

        if student_response.present?
          score = student_response.to_f
          total_score += score * weightage
          total_weight += weightage
        end
      end
      # Return the weighted average score
      total_weight > 0 ? (total_score / total_weight) : 0
    end
end
