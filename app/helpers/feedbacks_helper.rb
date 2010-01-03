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
    javascript_include_tag('prototype.feedback.js')
  end
  
  def feedback_link(text, options = {})
    xclass = ''
    if options.include?(:class)
      xclass = options[:class]
    end
    link_to text, '#', :class => "feedback_link " + xclass
  end

  def feedback_skillsets
    [ 'None',
      'Ruby/Rails Programming',
      'Web Design',
      'Graphic Design',
      'Marketing/PR',
      'Manual Labor',
      'Organizing People',
      'Other' ]
  end

  def feedback_bugtypes
    [ '',
      'found a bug',
      'feature request',
      'general feedback' ]
  end

  def feedback_select
    # logic for links and fields shown is in javascript
    subjects = [ { 'suggest' => 'suggest something' },
                 { 'volunteer' => 'volunteer for MAU' },
                 { 'gallery' => 'gallery interested'},
                 { 'business' => 'business interested'},
                 { 'donate' => 'donate to mau'},
                 { 'feedsuggest' => 'suggest a feed'},
                 { 'website' => 'website feedback'} ]
    cls = 'fdbk-subj'
    html = '<select>'
    subjects.each do |a|
      html += '<option>%s</option>' % a.values()[0]
    end
    html
  end

  def feedback_subjects
    # logic for links and fields shown is in javascript
    subjects = [ { 'general' => 'general feedback' },
                 { 'suggest' => 'suggest something' },
                 { 'volunteer' => 'volunteer for MAU' },
                 { 'gallery' => 'gallery interested'},
                 { 'business' => 'business interested'},
                 { 'donate' => 'donate to mau'},
                 { 'feedsuggest' => 'suggest a feed'},
                 { 'website' => 'website feedback'},
                 { 'emaillist' => 'get on our email list'}
               ]
    cls = 'fdbk-subj'
    html = ''
    subjects.each do |a|
      html += '<div class="%s"><a class="%s" href="#%s" >%s</a></div>' % [cls, cls, a.keys()[0], a.values()[0]]
    end
    html
  end
end
