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
        expect(node.attribute('data-section').value).to eq content.section
        expect(node.attribute('data-page').value).to eq content.page
        expect(node.attribute('data-cmsid').value).to eq content.id.to_s
        expect(node.attribute('class').value.split).to match_array(%w[section markdown])
      end
    end

    describe 'as an editor' do
      let(:user) { create(:user, :editor) }
      it 'renders a cms tag given a packaged CmsDocument with editor tags and classes' do
        content = create(:cms_document)
        tag = helper.render_cms_content(CmsDocument.packaged(content.page, content.section))
        node = Nokogiri::HTML::DocumentFragment.parse(tag).css('div')
        expect(node.attribute('data-section').value).to eq content.section
        expect(node.attribute('data-page').value).to eq content.page
        expect(node.attribute('data-cmsid').value).to eq content.id.to_s
        expect(node.attribute('class').value.split).to match_array(%w[section markdown editable])
      end

      it 'renders a cms tag for editing with new CMS document' do
        content = CmsDocument.packaged('SomewhereSection', 'WhereverPage')
        tag = helper.render_cms_content(content)
        node = Nokogiri::HTML::DocumentFragment.parse(tag).css('div')
        expect(node.attribute('data-section').value).to eq content[:section]
        expect(node.attribute('data-page').value).to eq content[:page]
        expect(node.attribute('data-cmsid')).to be_nil
        expect(node.attribute('class').value.split).to match_array(%w[section markdown editable editable--empty])
      end
    end
  end
end
