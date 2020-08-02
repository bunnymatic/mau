# frozen_string_literal: false

module CmsDocumentsHelper
  def render_cms_content(cms_content = nil)
    cms_content ||= {}
    data = cms_content.except(:content)
    clz = %( section markdown )
    if current_user.try(:editor?)
      clz << ' editable'
      clz << ' editable--empty' if cms_content[:content].blank?
      data[:'editable-content'] = true
    end

    tag.div({ data: data, class: clz }) do
      concat cms_content[:content]
      yield if block_given?
    end
  end
end
