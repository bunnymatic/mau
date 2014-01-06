require 'spec_helper'

describe AdminArtistList do

  fixtures :users, :roles, :roles_users

  let(:sort_by) { nil }
  let(:reverse) { nil }
  let(:parsed) { CSV.parse(list.csv,:headers => true) }
  
  subject(:list) { AdminArtistList.new(sort_by, reverse) }

  its(:csv_filename) { should eql 'mau_artists.csv' }
  its(:csv_headers) { should eql parsed.headers }
  it 'has correct data in the csv' do
    expect(parsed.first['Full name']).to eql list.artists.first.full_name
  end


  context 'default' do
    it 'sorts artist by studio id' do
      expect(list.artists.map{|a| a.studio_id.to_i}).to be_monotonically_increasing
    end
    
    context 'reverse=true' do
      let(:reverse) { true }
      it 'sorts artist by reverse studio id' do
        expect(list.artists.map{|a| a.studio_id.to_i}).to be_monotonically_decreasing
      end
      
    end
  end

  context 'sort by is an allowed field' do
    let(:sort_by) { :email }
    it 'sorts artist by that field' do
      expect(list.artists.map{|a| a.send(sort_by).to_s}).to be_monotonically_increasing
    end
    
    context 'reverse=true' do
      let(:reverse) { true }
      it 'sorts artist by reverse of that field' do
        expect(list.artists.map{|a| a.send(sort_by).to_s}).to be_monotonically_decreasing
      end
    end
  end

  context 'sort by is an disallowed field' do
    let(:sort_by) { :whatever }
    it 'sorts artist by that field' do
      expect(list.artists.map{|a| a.send(:studio_id).to_i}).to be_monotonically_increasing
    end
    
    context 'reverse=true' do
      let(:reverse) { true }
      it 'sorts artist by reverse of that field' do
        expect(list.artists.map{|a| a.send(:studio_id).to_i}).to be_monotonically_decreasing
      end
    end
  end

end
