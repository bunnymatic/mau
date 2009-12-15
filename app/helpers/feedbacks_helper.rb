module FeedbacksHelper 
  
  def feedback_tab(options = {})
    feedback_init({'position' => 'top'}.merge(options.stringify_keys))
  end
  
  def feedback_init(options = {})
    options = {
      "position" => "null"
    }.merge(options.stringify_keys)
    
    options['position'] = "'#{options['position']}'" unless options['position'].blank? || options['position'] == 'null'
    content_tag 'script', :type => "text/javascript" do
      "document.observe(\"dom:loaded\", function() { Feedback.init({tabPosition: #{options["position"]}}); });"
    end  
    
  end
  
  def feedback_includes()
    stylesheet_link_tag('feedback') +
    javascript_include_tag('prototype.feedback.js')
  end
  
  def feedback_link(text, options = {})
    link_to text, '#', :class => "feedback_link"
  end
  
end
