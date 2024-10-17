# This controller handles CRUD operations for Attributes nested under Forms
class AttributesController < ApplicationController
    # This before_action ensures @form is set before any action is executed
    before_action :set_form
    # This before_action sets @attribute only for the destroy action
    before_action :set_attribute, only: [ :destroy, :update_weightage ]

    # POST /forms/:form_id/attributes
    # Creates a new attribute for a specific form
    def create
        # Find the form using the form_id from the URL parameters
        @form = Form.find(params[:form_id])
        # Build a new attribute associated with the form, using permitted parameters
        @attribute = @form.form_attributes.build(attribute_params)

        if params[:attribute][:field_type] == "mcq"
            mcq_options = params[:mcq_options].reject(&:blank?) # Remove blank options
            @attribute.options = mcq_options.join(",") unless mcq_options.empty?
        end

        if @attribute.save
            # If save is successful, redirect to the form's edit page with a success notice
            redirect_to edit_form_path(@form), notice: "Attribute was successfully added."
        else
            # If save fails, redirect to the form's edit page with an error alert
            redirect_to edit_form_path(@form), alert: "Failed to add attribute."
        end
    end

    def update_weightage
        if weightage_params[:weightage].nil?
            redirect_to edit_form_path(@form), alert: "Failed to update weightage."
        else
            if @attribute.update(weightage_params)
              redirect_to edit_form_path(@form), notice: "Weightage was successfully updated."
            end
        end
    end

    # DELETE /forms/:form_id/attributes/:id
    # Removes an attribute from a specific form
    def destroy
        if @attribute.destroy
            # If destruction is successful, redirect to the form's edit page with a success notice
            redirect_to edit_form_path(@form), notice: "Attribute was successfully removed."
        else
            # If destruction fails, redirect to the form's edit page with an error alert
            redirect_to edit_form_path(@form), alert: "Failed to remove attribute."
        end
    end

    private

    # This method finds the parent Form for the nested Attribute
    # It's called by the before_action at the top of the controller
    def set_form
        # Find the form belonging to the current user using the form_id from the URL parameters
        @form = current_user.forms.find(params[:form_id])
    rescue ActiveRecord::RecordNotFound
        # If the form isn't found, redirect to the forms index with an alert
        flash[:alert] = "Form not found"
        redirect_to forms_path
    end

    # This method finds the specific attribute associated with the form
    # It's called by the before_action for the destroy action
    def set_attribute
        # Find the attribute belonging to the form using the id from the URL parameters
        @attribute = @form.form_attributes.find(params[:id])
    rescue ActiveRecord::RecordNotFound
        # If the attribute isn't found, redirect to the form's edit page with an alert
        flash[:alert] = "Attribute not found"
        redirect_to edit_form_path(@form)
    end

    # Strong parameters to prevent mass assignment vulnerabilities
    # This method defines which parameters are allowed when creating or updating an Attribute
    def attribute_params
        params.require(:attribute).permit(:name, :field_type, :min_value, :max_value, :options)
    end

    def weightage_params
        params.require(:attribute).permit(:weightage).tap do |whitelisted|
            if whitelisted[:weightage].present?
              whitelisted[:weightage] = whitelisted[:weightage].to_f
              if whitelisted[:weightage] < 0.0 || whitelisted[:weightage] > 1.0
                whitelisted[:weightage] = nil
              end
            end
          end
    end
end
