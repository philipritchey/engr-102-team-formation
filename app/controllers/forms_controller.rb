class FormsController < ApplicationController
  # Set up the @form instance variable for show, edit, update, and destroy actions
  before_action :set_form, only: %i[ show edit update destroy ]

  # GET /forms
  def index
    # TODO: Implement form listing logic
    @forms = Form.all
  end

  # GET /forms/1
  def show
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
    # Create a new Form with the submitted parameters
    @form = Form.new(form_params)

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
    respond_to do |format|
      if @form.update(form_params)
        format.html { redirect_to @form, notice: "Form was successfully updated." }
        format.json { render json: @form, status: :ok }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: { errors: @form.errors }, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /forms/1
  def destroy
    @form.destroy!

    respond_to do |format|
      # Redirect to index page after successful deletion
      format.html { redirect_to forms_path, status: :see_other, notice: "Form was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Fetch the Form object based on the id parameter
    def set_form
      @form = Form.find(params[:id])
    end

    # Define allowed parameters for form creation and update
    def form_params
      params.require(:form).permit(:name, :description)
    end
end
