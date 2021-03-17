module CmsDocumentsHelper
  def render_cms_content(cms_content = nil)
    cms_content ||= {}
    data = cms_content.except(:content)
    editor = current_user.try(:editor?)
    clz = class_names(['section', 'markdown', { editable: editor, "editable--empty": cms_content[:content].blank? }])

    tag.div({ class: clz }) do
      concat react_component(id: "editable-content-#{cms_content[:cmsid]}", component: 'EditableContentTrigger', props: data) if editor

      concat cms_content[:content]
      yield if block_given?
    end
  end
end
