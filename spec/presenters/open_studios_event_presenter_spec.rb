require 'rails_helper'

describe OpenStudiosEventPresenter do
  let(:os) { build_stubbed(:open_studios_event) }
  subject(:presenter) { described_class.new(os) }

  describe '.date_range' do
    context 'if the dates are in the same month' do
      let(:os) do
        build_stubbed(:open_studios_event,
                      start_date: Time.zone.local(2015, 5, 1, 10, 0, 0),
                      end_date: Time.zone.local(2015, 5, 2, 10, 0, 0))
      end

      it 'shows a pretty date' do
        expect(presenter.date_range).to eql 'May 1-2'
      end

      it 'uses the separator if provided' do
        expect(presenter.date_range(separator: ' & ')).to eql 'May 1 & 2'
      end
    end

    context 'if the dates are go across months' do
      let(:os) do
        build_stubbed(:open_studios_event,
                      start_date: Time.zone.local(2015, 4, 30, 10, 0, 0),
                      end_date: Time.zone.local(2015, 5, 1, 10, 0, 0))
      end

      it 'shows a pretty date' do
        expect(presenter.date_range).to eql 'Apr 30-May 1'
      end

      it 'uses the separator if provided' do
        expect(presenter.date_range(separator: ' & ')).to eql 'Apr 30 & May 1'
      end
    end
  end

  describe '.date_range_with_year' do
    let(:os) do
      build_stubbed(:open_studios_event,
                    start_date: Time.zone.local(2015, 4, 30, 10, 0, 0),
                    end_date: Time.zone.local(2015, 5, 1, 10, 0, 0))
    end

    it 'shows a pretty date with the year' do
      expect(presenter.date_range_with_year).to eql 'Apr 30-May 1 2015'
    end
  end

  describe '.special_event_date_range' do
    context 'if the dates are in the same month' do
      let(:os) do
        build_stubbed(:open_studios_event,
                      special_event_start_date: Time.zone.local(2015, 5, 1, 10, 0, 0),
                      special_event_end_date: Time.zone.local(2015, 5, 2, 10, 0, 0))
      end

      it 'shows a pretty date' do
        expect(presenter.special_event_date_range).to eql 'May 1-2'
      end

      it 'uses the separator if provided' do
        expect(presenter.special_event_date_range(separator: ' & ')).to eql 'May 1 & 2'
      end
    end

    context 'if the dates are go across months' do
      let(:os) do
        build_stubbed(:open_studios_event,
                      special_event_start_date: Time.zone.local(2015, 4, 30, 10, 0, 0),
                      special_event_end_date: Time.zone.local(2015, 5, 1, 10, 0, 0))
      end

      it 'shows a pretty date' do
        expect(presenter.special_event_date_range).to eql 'Apr 30-May 1'
      end

      it 'uses the separator if provided' do
        expect(presenter.special_event_date_range(separator: ' & ')).to eql 'Apr 30 & May 1'
      end
    end
  end

  describe '.special_event_date_range_with_year' do
    let(:os) do
      build_stubbed(:open_studios_event,
                    special_event_start_date: Time.zone.local(2015, 4, 30, 10, 0, 0),
                    special_event_end_date: Time.zone.local(2015, 5, 1, 10, 0, 0))
    end

    it 'shows a pretty date with the year' do
      expect(presenter.special_event_date_range_with_year).to eql 'Apr 30-May 1 2015'
    end
  end
end
