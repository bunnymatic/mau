require 'spec_helper'

describe ArtistPresenter do

  include PresenterSpecHelpers

  let(:user) { FactoryGirl.create(:artist, :activated) }
  let(:artist) { FactoryGirl.create(:artist, :activated, :with_art, :with_studio) }
  subject(:presenter) { ArtistPresenter.new(mock_view_context(user), artist) }

  its(:has_media?) { should be_true }
  its(:has_bio?) { should be_false }
  its(:allows_email_from_artists?) { should be_true }
  its(:has_links?) { should be_false }
  its(:links) { should be_empty }
  its(:fb_share_link) { should include "http://www.facebook.com\/sharer.php?u=#{artist.get_share_link(true)}" }
  its(:is_current_user?) { should be_false }
  its(:favorites_count) { should be_nil }
  its(:studio_name) { should be_present }

  context 'without media' do
    before do
      ArtPiece.any_instance.stub(:medium => nil)
    end
    its(:has_media?) { should be_false }
  end

  context 'with bio' do
    before do
      ArtistInfo.any_instance.stub(:bio => 'here we go')
      Artist.any_instance.stub(:bio => 'here we go')
    end
    its(:has_bio?) { should be_true }
  end

  context 'with links' do
    before do
      Artist.any_instance.stub(:facebook => 'http://facebookit.com')
    end
    its(:has_links?) { should be_true }
    its(:links) { should eql [[:u_facebook, 'Facebook', 'http://facebookit.com']] }
  end

  context 'when logged in' do
    subject(:presenter) { ArtistPresenter.new(mock_view_context(artist), artist) }
    its(:is_current_user?) { should be_true }
  end

  context 'without art' do
    let(:artist) { FactoryGirl.create(:artist, :activated) }
    its(:art_pieces) { should be_empty }
  end
end