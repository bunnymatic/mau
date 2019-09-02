# frozen_string_literal: true

require 'rails_helper'

describe ApplicationEventQuery do
  it 'returns number_of_records_query by default' do
    expect(subject).to be_valid
    expect(subject.number_of_records).to eq 100
  end

  it 'allows dates as Time, Date, ActiveRecord::TimeZone or DateTimes' do
    expect(described_class.new(since: 2.days.ago)).to be_valid
    expect(described_class.new(since: 2.days.ago.to_date)).to be_valid
    expect(described_class.new(since: 2.days.ago.to_datetime)).to be_valid
    # rubocop:disable Rails/Date
    expect(described_class.new(since: 2.days.ago.to_time)).to be_valid
    # rubocop:enable Rails/Date
  end

  it 'does not allow dates in the future' do
    expect(described_class.new(since: 2.days.since.to_s)).not_to be_valid
  end

  it 'does not allow number of records less than 1' do
    expect(described_class.new(number_of_records: 0)).not_to be_valid
    expect(described_class.new(number_of_records: -1)).not_to be_valid
  end

  it 'does not allow dates in the future by string' do
    expect(described_class.new(since: 2.days.since.to_s)).not_to be_valid
  end

  it 'does not allow setting both since and number_of_records' do
    expect(described_class.new(number_of_records: 20, since: 2.days.since.to_s)).not_to be_valid
  end

  describe '.to_s' do
    before do
      Timecop.freeze
    end
    it 'renders the query as a string with the date' do
      query = described_class.new(since: '2018-10-20')
      expect(query.to_s).to eq 'Since 2018-10-20'
    end
  end
end
