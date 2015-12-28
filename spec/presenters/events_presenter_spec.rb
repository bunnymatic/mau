require 'spec_helper'

describe EventsPresenter do

  include PresenterSpecHelpers

  let(:events) { Event.published }
  let(:month_year_key) { nil }
  subject(:presenter) { EventsPresenter.new(mock_view_context, events, month_year_key) }

  describe '#current' do
    subject { super().current }
    it { should be_nil }
  end

end
