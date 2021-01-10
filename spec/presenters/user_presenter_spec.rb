# frozen_string_literal: true

require 'rails_helper'

describe UserPresenter do
  include PresenterSpecHelpers

  let(:created) { 1.year.ago }
  let(:activated) { nil }
  let(:last_login_at) { 1.day.ago }
  let(:last_request_at) { 1.minute.ago }
  let(:current_login_at) { 1.hour.ago }
  let(:user) do
    create :artist,
           created_at: created,
           activated_at: activated,
           last_request_at: last_request_at,
           last_login_at: last_login_at,
           current_login_at: current_login_at
  end
  subject(:presenter) { described_class.new(user) }

  its(:member_since) { is_expected.to eql created.strftime('%b %Y') }

  describe '#last_login' do
    its(:last_login) { is_expected.to eql user.last_request_at.to_formatted_s(:admin) }
    context 'when last_request_at is not present' do
      let(:last_request_at) { nil }
      its(:last_login) { is_expected.to eql user.current_login_at.to_formatted_s(:admin) }
    end
    context 'when last_request_at and current_login are not present' do
      let(:last_request_at) { nil }
      let(:current_login_at) { nil }
      its(:last_login) { is_expected.to eql user.last_login_at.to_formatted_s(:admin) }
    end
  end

  describe '#member_since_date' do
    context 'when activated_at is unset' do
      it 'computes member_since_date using created_at' do
        expect(presenter.member_since_date.to_date).to eql(created.to_date)
      end
    end
    context 'when activated_at is set' do
      let(:activated) { 9.months.ago }
      it 'computes member_since_date using activated_at' do
        expect(presenter.member_since_date.to_date).to eql(activated.to_date)
      end
    end
  end

  describe '.icon_link_class' do
    it 'returns ico-tumblr for www.whatever.tumblr.com' do
      clz = described_class.send(:icon_link_class, :blog, 'http://www.whatever.tumblr.com')
      expect(clz).to include 'ico-tumblr'
      expect(clz).to include 'ico-blog'
    end

    it 'returns ico-tumblr for whatever.tumblr.com' do
      clz = described_class.send(:icon_link_class, :blog, 'http://whatever.tumblr.com')
      expect(clz).to include 'ico-tumblr'
    end

    it 'returns ico-blogger for www.blogger.com' do
      clz = described_class.send(:icon_link_class, :blog, 'http://www.blogger.com')
      expect(clz).to include 'ico-blogger'
    end

    it 'returns ico-twitter for www.twitter.com/herewego' do
      clz = described_class.send(:icon_link_class, :twitter, 'whatever')
      expect(clz).to include 'ico-twitter'
    end
  end

  describe '#links_html' do
    it 'shows html links' do
      links = Nokogiri::HTML(presenter.links_html.first)
      expect(links.css("a[href=\"#{user.links.first[1]}\"] i")).to have(1).item
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

    it 'includes only active artists' do
      expect(presenter.who_i_favorite).to include active_with_art
      expect(presenter.who_i_favorite).not_to include inactive_with_art
    end

    it 'does not include art' do
      expect(presenter.who_i_favorite.any? { |f| f.is_a? ArtPiece }).to eq false
    end

    it 'does not include fans' do
      expect(presenter.who_i_favorite).not_to include fan
    end
  end
end
