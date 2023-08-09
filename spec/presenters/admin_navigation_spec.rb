require 'rails_helper'

describe AdminNavigation do
  include PresenterSpecHelpers

  let(:user) { FactoryBot.create(:user, :admin, :active) }
  let(:studio) { FactoryBot.create(:studio) }
  subject(:nav) { AdminNavigation.new(user) }

  it { expect(subject.links.map(&:first)).to eq %i[models pr admin internal] }

  describe 'as a manager' do
    let(:user) { FactoryBot.create(:user, :manager, :active, studio:) }
    it { expect(subject.links.last.last.map(&:first)).to eq [:studios] }
  end

  describe 'as an editor' do
    let(:user) { FactoryBot.create(:user, :editor, :active) }
    it { expect(subject.links.last.last.map(&:first)).to eq %i[events cms_documents] }
  end
end
