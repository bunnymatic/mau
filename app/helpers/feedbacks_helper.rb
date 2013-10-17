module FeedbacksHelper

  # def feedback_tab(options = {})
  #   feedback_init({'position' => 'top'}.merge(options.stringify_keys))
  # end

  # def feedback_init(options = {})
  #   options = {
  #     "position" => "null"
  #   }.merge(options.stringify_keys)

  #   options['position'] = "'#{options['position']}'" unless options['position'].blank? || options['position'] == 'null'
  #   content_tag 'script', :type => "text/javascript" do
  #     "document.observe(\"dom:loaded\", function() { Feedback.init({tabPosition: #{options["position"]}}); });"
  #   end

  # end

  # def feedback_includes
  # end

  def feedback_link(text, options = {})
    xclass = ''
    if options.include?(:class)
      xclass = options[:class]
    end
    link_to text, '#', :class => "feedback_link " + xclass
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

  # def feedback_bugtypes
  #   [ '',
  #     'Found a bug',
  #     'Feature request',
  #     'General feedback' ]
  # end

  # def feedback_subjects(section='general')
  #   # logic for links and fields shown is in javascript
  #   subjects = [ { 'general' => 'General feedback' },
  #                { 'suggest' => 'Suggestion' },
  #                { 'volunteer' => 'Volunteer for MAU' },
  #                { 'gallery' => 'Gallery interest'},
  #                { 'business' => 'Local Business interest'},
  #                { 'donate' => 'Donate to MAU'},
  #                { 'feedsuggest' => 'Suggest a feed'},
  #                { 'website' => 'Website Feedback'},
  #               { 'emaillist' => 'Get on the MAU email list'}
  #              ]
  #   html = ''
  #   subjects.each do |a|
  #     cls = 'fdbk-subj'
  #     kk = a.keys()[0]
  #     vv = a.values()[0]
  #     html += '<div class="%s"><a class="%s" href="#%s" >%s<div id="next_pg"></div></a></div>' % [cls, cls, kk, vv]
  #   end
  #   html
  # end
end
