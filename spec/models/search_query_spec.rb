require 'spec_helper'

describe SearchQuery do

  its(:keywords) { should be_empty }
  its(:mediums) { should be_empty }
  its(:studios) { should be_empty }
  its(:os_flag) { should be_nil }
  its(:page) { should eql 0}
  its(:mode) { should be_nil }
  its(:query) { should be_blank }
  its(:per_page) { should eql MauSearchQuery::PER_PAGE }

end
