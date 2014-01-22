require 'spec_helper'

describe EventsPresenter do

  include PresenterSpecHelpers

  fixtures :users, :artist_infos, :studios, :art_pieces, :media, :roles, :roles_users

  let(:events) { Event.published }
  let(:month_year_key) { nil }
  subject(:presenter) { EventsPresenter.new(mock_view_context, events, month_year_key) }

  its(:current) { should be_nil }

end
