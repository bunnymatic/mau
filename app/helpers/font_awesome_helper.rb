module FontAwesomeHelper

  def fa_icon(ico)
    content_tag 'i', '', class: "fa fa-#{ico}"
  end

end
