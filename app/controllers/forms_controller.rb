# This controller handles CRUD operations for forms
# It also includes functionality for uploading and validating user data

class FormsController < ApplicationController
  require "roo"

  # Set @form instance variable for show, edit, update, and destroy actions
  before_action :set_form, only: %i[ show edit update destroy ]

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
  def update
    # Allow params with or without 'form' key
    update_params = params[:form] || params

    if @form.update(update_params.permit(:name, :description))
      # If update succeeds, set success message and redirect to the form
      flash[:notice] = "Form was successfully updated."
      redirect_to @form
    else
      # If update fails, rebuild the attribute and re-render the edit form
      @attribute = @form.form_attributes.build
      render :edit, status: :unprocessable_entity
    end
  end

  # GET /forms/#id/preview
  def preview
    @form = Form.find(params[:id])
    render partial: "preview"
  end

  #GET /forms/#id/duplicate
  #opens new /forms/#new_id/edit
  def duplicate
    original_form = Form.find(params[:id])
    duplicated_form = original_form.dup

    # Suggest a new name for the duplicated form
    duplicated_form.name = "#{original_form.name} - Copy"

    # Duplicate associated attributes
    original_form.form_attributes.each do |attribute|
      duplicated_attribute = attribute.dup
      duplicated_attribute.assign_attributes(attribute.attributes.except("id", "created_at", "updated_at", "form_id"))
      duplicated_form.form_attributes << duplicated_attribute
    end

    if duplicated_form.save
      # Redirect to the edit page of the duplicated form in a new window
      redirect_to edit_form_path(duplicated_form), notice: "Form was successfully duplicated."
    else
      redirect_to edit_form_path(original_form), alert: "Failed to duplicate the form."
    end
  end


  def upload
  end

  def validate_upload
    if params[:file].present?
      file = params[:file].path

      begin
        spreadsheet = Roo::Spreadsheet.open(file)
        header_row = spreadsheet.row(1)

        if header_row.nil? || header_row.all?(&:blank?)
          flash[:alert] = "The first row is empty. Please provide column names."
          redirect_to user_path(@current_user) and return
        end

        name_index = header_row.index("Name") || -1
        uin_index = header_row.index("UIN") || -1
        email_index = header_row.index("Email ID") || -1

        unless name_index >= 0 && uin_index >= 0 && email_index >= 0
          flash[:alert] = "Missing required columns. Ensure 'Name', 'UIN', and 'Email ID' are present."
          redirect_to user_path(@current_user) and return
        end

        users_to_create = []
        (2..spreadsheet.last_row).each do |index|
          row = spreadsheet.row(index)

          if row[name_index].blank?
            flash[:alert] = "Missing value in 'Name' column for row #{index}."
            redirect_to user_path(@current_user) and return
          end

          uin_value = row[uin_index]
          unless uin_value.is_a?(String) && uin_value.match?(/^\d{9}$/)
            flash[:alert] = "Invalid UIN in 'UIN' column for row #{index}. It must be a 9-digit number."
            redirect_to user_path(@current_user) and return
          end

          email_value = row[email_index]
          if email_value.blank?
            flash[:alert] = "Missing value in 'Email ID' column for row #{index}."
            redirect_to user_path(@current_user) and return
          end

          unless email_value =~ /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
            flash[:alert] = "Invalid email in 'Email ID' column for row #{index}."
            redirect_to user_path(@current_user) and return
          end
          users_to_create << {
            name: row[name_index],
            uin: uin_value,
            email: email_value
          }
        end
        User.insert_all(users_to_create)
        flash[:notice] = "All validations passed."

      rescue Roo::FileNotFound
        flash[:alert] = "File not found. Please upload a valid Excel or CSV file."
      rescue StandardError => e
        flash[:alert] = "An error occurred: #{e.message}"
      end
    else
      flash[:alert] = "Please upload a file."
    end

    redirect_to user_path(@current_user)
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

  private
    # Sets @form instance variable based on the id parameter
    # Only finds forms belonging to the current user for security
    def set_form
      @form = current_user.forms.find(params[:id])
    end

    # Define allowed parameters for form creation and update
    # This is a security measure to prevent mass assignment vulnerabilities
    def form_params
      params.require(:form).permit(:name, :description)
    rescue ActionController::ParameterMissing
      # If :form key is missing, permit name and description directly from params
      # This allows for more flexible parameter handling
      params.permit(:name, :description)
    end
end
