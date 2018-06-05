# frozen_string_literal: false

module CmsDocumentsHelper
  def render_cms_content(cms_content = nil)
    cms_content ||= {}
    data = Hash[cms_content.except(:content).map { |(key, val)| ["data-#{key}", val] }]
    clz = %( section markdown )
    if current_user.try(:editor?)
      clz << ' editable'
      clz << ' editable--empty' if cms_content[:content].blank?
      data[:'editable-content'] = true
    end
    data[:class] = clz

    content_tag(:div, data.merge(class: clz)) do
      concat cms_content[:content]
      yield if block_given?
    end
  end
end
