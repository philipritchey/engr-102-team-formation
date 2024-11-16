module AttributeHelpers
  extend ActiveSupport::Concern

  private

  def skip_weightage?(attribute)
    [ "gender", "ethnicity" ].include?(attribute.name.downcase)
  end

  def mcq_field?
    params[:attribute][:field_type] == "mcq"
  end

  def set_mcq_options(attribute)
    mcq_options = params[:mcq_options].reject(&:blank?)
    attribute.options = mcq_options.join(",") unless mcq_options.empty?
  end

  def build_attribute
    @form.form_attributes.build(attribute_params).tap do |attr|
      set_mcq_options(attr) if mcq_field?
    end
  end
end
