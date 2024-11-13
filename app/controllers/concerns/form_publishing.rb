module FormPublishing
  extend ActiveSupport::Concern

  def publish
    if @form.can_publish?
      publish_form
    else
      handle_publish_error
    end
  end

  def close
    if @form.update(published: false)
      redirect_to @form, notice: "Form was successfully closed."
    else
      redirect_to @form, alert: "Failed to close the form."
    end
  end

  private

  def publish_form
    if @form.update(published: true)
      redirect_to @form, notice: "Form was successfully published."
    else
      redirect_to @form, alert: "Failed to publish the form."
    end
  end

  def handle_publish_error
    reasons = collect_error_reasons
    flash[:alert] = "Form cannot be published. Reasons: #{reasons.join(', ')}."
    redirect_to @form
  end

  def collect_error_reasons
    error_conditions = {
      "no gender attribute" => !@form.has_gender_attribute?,
      "no ethnicity attribute" => !@form.has_ethnicity_attribute?,
      "no associated students" => !@form.has_associated_students?
    }

    # Collect all the reasons where the condition is true
    error_conditions.select { |_, condition| condition }.keys
  end
end
