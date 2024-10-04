class FormsController < ApplicationController
  require "roo"
  before_action :set_form, only: %i[ show edit update destroy ]

  # GET /forms
  def index
    # TODO: Implement form listing logic
    @forms = Form.all
  end

  # GET /forms/1
  def show
    puts "Show action started"  # Debug line
    # @form is already set by before_action
  end

  # GET /forms/new
  def new
    # Initialize a new Form object for the form builder
    @form = Form.new
  end

  # GET /forms/1/edit
  def edit
    @attribute = @form.form_attributes.build
  end

  # POST /forms
  def create
    @form = current_user.forms.build(form_params)

    if @form.save
      # Redirect to edit page to add attributes after successful creation
      redirect_to edit_form_path(@form), notice: "Form was successfully created. You can now add attributes."
    else
      # Re-render the new form if save fails
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /forms/1
  def update
    puts "Update action started"  # Debug line
    update_params = params[:form] || params
    puts "Update params: #{update_params.inspect}"  # Debug line

    if @form.update(update_params.permit(:name, :description))
      puts "Form updated successfully"  # Debug line
      flash[:notice] = "Form was successfully updated."
      redirect_to @form
    else
      puts "Form update failed"  # Debug line
      flash.now[:alert] = @form.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_entity
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
        puts "First row content: #{header_row.inspect}"

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
  def destroy
    @form.destroy!

    respond_to do |format|
      # Redirect to user's show page after successful deletion
      format.html { redirect_to user_path(current_user), status: :see_other, notice: "Form was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    def set_form
      @form = current_user.forms.find(params[:id])
    end

    # Define allowed parameters for form creation and update
    def form_params
      params.require(:form).permit(:name, :description)
    rescue ActionController::ParameterMissing
      # If :form key is missing, permit name and description directly from params
      params.permit(:name, :description)
    end
end
