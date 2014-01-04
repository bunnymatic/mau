require 'spec_helper'

describe StudiosPresenter do
  
  fixtures :studios, :users

  let(:studios) { Studio.all }
  let(:view_mode) { 'name' }
  subject(:presenter) { StudiosPresenter.new(studios, view_mode) }

  it 'studios are sorted by name with indy at the bottom' do
    list = presenter.studios
    expect(list.pop).to eql Studio.indy
    expect(list.map{|s| s.name.downcase}).to be_monotonically_increasing
  end
 
  context 'view mode is count' do
    let(:view_mode) { 'count' }
    it 'studios are sorted by active artist count' do
      list = presenter.studios
      expect(list.map{|s| s.active_artists.count}).to be_monotonically_decreasing
    end
  end
   
end
