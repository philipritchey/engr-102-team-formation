module ApplicationHelper
  def bootstrap_class_for(flash_type)
    case flash_type.to_sym
    when :notice then "alert-success"
    when :alert then "alert-warning"
    when :error then "alert-danger"
    else "alert-info"
    end
  end
end
