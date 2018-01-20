# frozen_string_literal: true

require 'rails_helper'

describe StudiosPresenter do
  let(:studios) { Studio.all }
  subject(:presenter) { StudiosPresenter.new(studios) }

  it 'studios are sorted by name with indy at the bottom' do
    expect(presenter.studios.map { |s| s.name.downcase }).to be_monotonically_increasing
  end
end
