module FeedbacksHelper
  def feedback_link(text, options = {})
    link_to text, '#', class: (['feedback_link', options[:class]].compact.join ' ')
  end
end
