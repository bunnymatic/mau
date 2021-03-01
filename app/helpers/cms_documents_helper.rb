module CmsDocumentsHelper
  def render_cms_content(cms_content = nil)
    cms_content ||= {}
    data = cms_content.except(:content)
    editor = current_user.try(:editor?)
    clz = class_names(['section', 'markdown', { editable: editor, "editable--empty": cms_content[:content].blank? }])
    data[:'editable-content'] = true if editor

    tag.div({ data: data, class: clz }) do
      concat cms_content[:content]
      yield if block_given?
    end
  end
end
