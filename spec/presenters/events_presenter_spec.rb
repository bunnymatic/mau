require 'spec_helper'

describe EventsPresenter do

  include PresenterSpecHelpers

  let(:events) { Event.published }
  let(:month_year_key) { nil }
  subject(:presenter) { EventsPresenter.new(mock_view_context, events, month_year_key) }

  its(:current) { should be_nil }

end
