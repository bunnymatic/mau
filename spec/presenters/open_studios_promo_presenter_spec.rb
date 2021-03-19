require 'rails_helper'

describe OpenStudiosPromoPresenter do
  subject(:presenter) { described_class.new(nil) }
  let!(:summary) do
    create(:cms_document,
           page: :main_openstudios,
           section: :summary,
           article: "# spring 2004\n\n## spring 2004 header2 \n\nwhy _spring_.")
  end
  let!(:preview_reception) do
    create(:cms_document,
           page: :main_openstudios,
           section: :preview_reception,
           article: "# pr header\n\n## pr header2\n\ncome out to the *preview* receiption")
  end

  describe '#packaged_summary' do
    it 'returns the cms data ready to render' do
      expect(subject.packaged_summary).to eq({
                                               cmsid: summary.id,
                                               page: summary.page,
                                               section: summary.section,
                                               content: MarkdownService.markdown(summary.article),
                                             })
    end
  end

  describe '#packaged_preview_reception' do
    it 'returns the cms data ready to render' do
      expect(subject.packaged_preview_reception).to eq({
                                                         cmsid: preview_reception.id,
                                                         page: preview_reception.page,
                                                         section: preview_reception.section,
                                                         content: MarkdownService.markdown(preview_reception.article),
                                                       })
    end
  end
end
