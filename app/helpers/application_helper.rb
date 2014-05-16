module ApplicationHelper
  def application_body_class
    [@current_controller, @body_classes].flatten.compact.uniq.join ' '
  end
end
