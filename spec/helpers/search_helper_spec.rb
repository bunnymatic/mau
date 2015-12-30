require 'rails_helper'

describe SearchHelper do
  include SearchHelper
  describe 'get_pages_for_pagination' do
    it 'returns the first 3 pages if there are more than 3' do
      expect(get_pages_for_pagination(0,10)[0..2]).to eq([0,1,2])
    end
    it 'returns the last 3 pages if there are more than 3' do
      pages = get_pages_for_pagination(0,12)
      expect(pages[(pages.length-3)..-1]).to eq([9,10,11])
    end
    it 'returns 1,2,3,4,5 ... 10,11,12 when there are 12 pages and current is 3' do
      expect(get_pages_for_pagination(2,12)).to eq([0,1,2,3,9,10,11])
    end
    it 'returns 1,2,3,4,5 ... 10,11,12 when there are 12 pages and current is 4' do
      expect(get_pages_for_pagination(3,12)).to eq([0,1,2,3,4,9,10,11])
    end
    it 'returns 1,2,3, ... 8,9,10,11,12 when there are 12 pages and current is 9' do
      expect(get_pages_for_pagination(8,12)).to eq([0,1,2,7,8,9,10,11])
    end
    it 'returns 1,2,3, ... 7,8,9,10,11,12 when there are 12 pages and current is 8' do
      expect(get_pages_for_pagination(7,12)).to eq([0,1,2,6,7,8,9,10,11])
    end
    it 'returns 1,2,3 ... 6,7,8 ... 10,11,12 when there are 12 pages and current is 7' do
      expect(get_pages_for_pagination(6,12)).to eq([0,1,2,5,6,7,9,10,11])
    end
    it 'returns 1,2,3,4,5,6 ... 10,11,12 when there are 12 pages and current is 6' do
      expect(get_pages_for_pagination(5,12)).to eq([0,1,2,4,5,6,9,10,11])
    end
    it 'returns 1,2 when there are 2 pages' do
      expect(get_pages_for_pagination(0,2)).to eq([0,1])
      expect(get_pages_for_pagination(1,2)).to eq([0,1])
      expect(get_pages_for_pagination(2,2)).to eq([0,1])
    end
    it 'returns all pages when there are 7 independent of current' do
      6.times do |x|
        expect(get_pages_for_pagination(x,6)).to eq([0,1,2,3,4,5])
      end
    end
  end

end
