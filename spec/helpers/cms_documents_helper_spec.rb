require 'rails_helper'

describe CmsDocumentsHelper do
  # force helper to implement current_user (which comes from helper methods and should be available
  helper do
    def current_user; end
  end

  describe '#render_cms_content' do
    let(:user) {}
    before do
      allow(helper).to receive(:current_user).and_return user
    end
    describe 'as a non editor' do
      it 'renders a cms tag given a packaged CmsDocument' do
        content = create(:cms_document)
        tag = helper.render_cms_content(CmsDocument.packaged(content.page, content.section))
        node = Nokogiri::HTML::DocumentFragment.parse(tag).css('div')
        expect(node.attribute('class').value.split).to match_array(%w[section markdown])
      end
    end

    describe 'as an editor' do
      let(:user) { create(:user, :editor) }
      it 'renders a cms tag given a packaged CmsDocument with editor tags and classes' do
        content = create(:cms_document)
        tag = helper.render_cms_content(CmsDocument.packaged(content.page, content.section))
        node = Nokogiri::HTML::DocumentFragment.parse(tag).css('div')
        expect(node.attribute('class').value.split).to match_array(%w[section markdown editable])
        react_component_node = node.css('.react-component')
        expect(react_component_node.attribute('data-component').value).to eq 'EditableContentTrigger'
        expect(react_component_node.attribute('data-react-props').value).to eq({
          page: content.page,
          section: content.section,
          cmsid: content.id,
        }.to_json)
      end

      it 'renders a cms tag for editing with new CMS document' do
        content = CmsDocument.packaged('WhereverPage', 'SomewhereSection')
        tag = helper.render_cms_content(content)
        node = Nokogiri::HTML::DocumentFragment.parse(tag).css('div')
        expect(node.attribute('class').value.split).to match_array(%w[section markdown editable editable--empty])
        react_component_node = node.css('.react-component')
        expect(react_component_node.attribute('data-component').value).to eq 'EditableContentTrigger'
        expect(react_component_node.attribute('data-react-props').value).to eq({
          page: 'WhereverPage',
          section: 'SomewhereSection',
        }.to_json)
      end
    end
  end
end
