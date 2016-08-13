require "rails_helper"

describe UserPresenter do

  include PresenterSpecHelpers

  let(:user) { create :artist, created_at: 1.year.ago }
  subject(:presenter) { described_class.new(user) }

  its(:member_since) { Time.current.year - 1 }

  describe '#icon_link_class' do

    it 'returns ico-tumblr for www.whatever.tumblr.com' do
      clz = presenter.send(:icon_link_class, :blog, 'http://www.whatever.tumblr.com')
      expect(clz).to include 'ico-tumblr'
      expect(clz).to include 'ico-blog'
    end

    it 'returns ico-tumblr for whatever.tumblr.com' do
      clz = presenter.send(:icon_link_class, :blog, 'http://whatever.tumblr.com')
      expect(clz).to include 'ico-tumblr'
    end

    it 'returns ico-blogger for www.blogger.com' do
      clz = presenter.send(:icon_link_class, :blog, 'http://www.blogger.com')
      expect(clz).to include 'ico-blogger'
    end

    it 'returns ico-twitter for www.twitter.com/herewego' do
      clz = presenter.send(:icon_link_class, :twitter, 'whatever')
      expect(clz).to include 'ico-twitter'
    end

  end

  describe '#links_html' do

    it 'shows html links' do
      expect(presenter.links_html.join).to match(/#{user.links.first}/)
    end

  end

  describe '#who_i_favorite' do
    let(:active_with_art) { create :artist, :active, :with_art }
    let(:inactive_with_art) { create :artist, :with_art, state: :suspended }
    let(:fan) { create :fan }

    before do
      create_favorite user, active_with_art
      create_favorite user, inactive_with_art
      create_favorite user, fan
      create_favorite user, inactive_with_art.art_pieces.first
      create_favorite user, active_with_art.art_pieces.first
    end

    it "includes only active artists" do
      expect(presenter.who_i_favorite).to include active_with_art
      expect(presenter.who_i_favorite).not_to include inactive_with_art
    end

    it "does not include art" do
      expect(presenter.who_i_favorite.any?{|f| f.is_a? ArtPiece}).to eq false
    end

    it "does not include fans" do
      expect(presenter.who_i_favorite).not_to include fan
    end
  end


end
