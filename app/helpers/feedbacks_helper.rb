module FeedbacksHelper

  def feedback_link(text, options = {})
    link_to text, '#', :class => (["feedback_link", options[:class]].compact.join '')
  end

  def feedback_skillsets
    [ 'None',
      'Web Design/Programming',
      'Graphic Design',
      'Marketing/PR',
      'Manual Labor',
      'Organizing People',
      'Other' ]
  end

end
