require "rails_helper"

describe UserPresenter do

  include PresenterSpecHelpers

  let(:user) { create :artist, created_at: 1.year.ago }
  subject(:presenter) { described_class.new(user) }

  its(:member_since) { Time.current.year - 1 }

  describe '#what_i_favorite' do
    let(:active_with_art) { create :artist, :active, :with_art }
    let(:inactive_with_art) { create :artist, :with_art, state: :suspended }
    let(:fan) { create :fan }

    before do
      user.add_favorite active_with_art
      user.add_favorite inactive_with_art
      user.add_favorite fan
      user.add_favorite inactive_with_art.art_pieces.first
      user.add_favorite active_with_art.art_pieces.first
    end

    it "includes only active artists" do
      expect(presenter.what_i_favorite).to include active_with_art
      expect(presenter.what_i_favorite).not_to include inactive_with_art
    end

    it "includes only art from active artists" do
      expect(presenter.what_i_favorite).to include active_with_art.art_pieces.first
      expect(presenter.what_i_favorite).not_to include inactive_with_art.art_pieces.first
    end

    it "does not include fans" do
      expect(presenter.what_i_favorite).not_to include fan
    end
  end


end
