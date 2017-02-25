# frozen_string_literal: true
require 'rails_helper'

describe AdminNavigation do
  include PresenterSpecHelpers

  let(:user) { FactoryGirl.create(:user, :admin, :active) }
  let(:studio) { FactoryGirl.create(:studio) }
  subject(:nav) { AdminNavigation.new(user) }

  it { expect(subject.links.map(&:first)).to eq [:models, :pr, :admin, :internal] }

  describe 'as a manager' do
    let(:user) { FactoryGirl.create(:user, :manager, :active, studio: studio) }
    it { expect(subject.links.last.last.map(&:first)).to eq [:studios] }
  end

  describe 'as an editor' do
    let(:user) { FactoryGirl.create(:user, :editor, :active ) }
    it { expect(subject.links.last.last.map(&:first)).to eq [:events, :cms_documents] }
  end
end
