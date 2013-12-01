require 'spec_helper'

describe ArtistPresenter do

  include PresenterSpecHelpers

  let(:artist) { FactoryGirl.create(:artist, :activated, :with_art ) }
  subject(:presenter) { ArtistPresenter.new(mock_view_context, artist) }

  its(:has_media) { should be_false? }
  its(:has_bio) { should be_true }
  its(:allows_email_from_artists?) { should be_false }
  its(:has_links?) { should be_true }
  its(:links) { should eql {} }
  its(:fb_share_link) { should match /^http:\/\/www.facebook.com\/sharer.php\?u#{artist.get_share_link(true)}/ }
  its(:is_current_user?) { should be_false }
end
