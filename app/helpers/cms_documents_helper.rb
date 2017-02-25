# frozen_string_literal: true
module CmsDocumentsHelper
  def render_cms_content(cms_content = nil)
    cms_content ||= {}
    data = Hash[cms_content.except(:content).map { |(key, val)| ['data-%s' % key, val] }]
    clz = %( section markdown )
    clz << 'editable' if current_user.try(:is_editor?)
    content_tag(:div, data.merge(class: clz)) do
      concat cms_content[:content]
      yield if block_given?
    end
  end
end
