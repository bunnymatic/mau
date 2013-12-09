require 'spec_helper'

describe MediumPagination do

  include PresenterSpecHelpers

  fixtures :media

  let(:num_items) { 8 }
  let(:per_page) { 3 }
  let(:current_page) { 0 }
  let(:medium) { Medium.last }

  subject(:paginator) { MediumPagination.new(mock_view_context, num_items.times.map{|x| x + 1}, medium, current_page, per_page ) }

  its(:previous_title) { should eq 'previous' }
  its(:previous_label) { should eq '&lt;prev' }
  its(:next_title) { should eq 'next' }
  its(:next_label) { should eq 'next&gt;' }
  its(:next_link) { should eq mock_view_context.medium_path(medium, :p => 1) }
  its(:previous_link) { should eq mock_view_context.medium_path(medium, :p => 0) }

end
