require 'rails_helper'

describe OpenStudiosPresenter do
  subject(:presenter) { described_class.new }
  let(:open_studios_event) { create(:open_studios_event) }
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

  before do
    allow(OpenStudiosEventService).to receive(:current).and_return(open_studios_event)
    allow(open_studios_event).to receive_message_chain(:artists, :in_the_mission)
      .and_return(
        [
          instance_double(Artist, studio: instance_double(Studio, name: 'studio')),
          instance_double(Artist, studio: instance_double(Studio, name: 'axe')),
          instance_double(Artist, studio: nil, address: 'mission', lastname: 'Rogers'),
          instance_double(Artist, studio: nil, address: 'mission', lastname: 'Jill'),
        ],
      )
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

  describe '#participating_studios' do
    it 'has 2 studios' do
      expect(presenter.participating_studios.size).to eq(2)
    end
    it 'are in order by studio name' do
      expect(subject.participating_studios.map(&:name)).to be_monotonically_increasing
    end
  end

  describe '#participating_indies' do
    it 'has 2 artists' do
      expect(presenter.participating_indies.size).to eq(2)
    end
    it 'in order by artist last name' do
      expect(subject.participating_indies.map(&:lastname).map(&:downcase)).to be_monotonically_increasing
    end
  end
end
