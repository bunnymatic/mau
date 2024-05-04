require 'rails_helper'

describe OpenStudiosEventPresenter do
  let(:os) { build_stubbed(:open_studios_event) }
  subject(:presenter) { described_class.new(os) }

  describe '==' do
    let(:comparison_event) { build_stubbed(:open_studios_event) }
    it 'is true for an os event that matches the presented event' do
      expect(presenter == os).to eq true
    end
    it 'is true for the same presenter' do
      expect(presenter == presenter).to eq true # rubocop:disable Lint/BinaryOperatorWithIdenticalOperands
    end
    it "is false if they don't line up" do
      expect(presenter == comparison_event).to eq false
    end
    it "is false if they're not the same thing at all" do
      expect(presenter == 'whatever').to eq false
    end
    it 'is true for 2 presenters that wrap the same os event' do
      expect(presenter == described_class.new(os))
    end
    it 'the equality must start with the presenter otherwise you\'re getting OpenStudiosEvent#==' do
      expect(os == presenter).to eq false
    end
  end

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

  describe '.active?' do
    let(:today) { Time.current.to_date }
    it 'returns true if there is no activated/deactivated date' do
      event = described_class.new(os)
      expect(event.active?).to eq true
    end
    it 'returns true if todays date is equal to the activated_at' do
      event = described_class.new(build(:open_studios_event, activated_at: today, deactivated_at: today + 2.days))
      expect(event.active?).to eq true
    end
    it 'returns true if todays date is equal to the deactivated_at' do
      event = described_class.new(build(:open_studios_event, activated_at: today - 2.days, deactivated_at: today))
      expect(event.active?).to eq true
    end
    it 'returns true if todays date is between activation dates' do
      event = described_class.new(build(:open_studios_event, activated_at: today - 1.day, deactivated_at: today + 1.day))
      expect(event.active?).to eq true
    end
    it 'returns false if todays date is before activated_at' do
      event = described_class.new(build(:open_studios_event, activated_at: today + 2.days, deactivated_at: today - 4.days))
      expect(event.active?).to eq false
    end

    it 'returns false if todays date is after deactivated_at' do
      event = described_class.new(build(:open_studios_event, activated_at: today - 4.days, deactivated_at: today - 2.days))
      expect(event.active?).to eq false
    end
  end

  # describe '.banner_image_url' do
  #   let(:os) { build_stubbed(:open_studios_event, :with_banner_image) }
  #   it 'returns correct banner image url' do
  #     presented_event = described_class.new(os)
  #     expect(presented_event.banner_image_url).to eq("garbage")
  #   end
  # end
end
