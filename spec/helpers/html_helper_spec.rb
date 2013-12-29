require 'spec_helper'

describe HtmlHelper do

  describe '.encode' do
    it 'encodes html entities in the string' do
      q = helper.html_encode('encode me <> & _ @$# yo!');
      expect(q).to eql 'encode me &#x3c;&#x3e; &#x26; _ @$# yo!'
    end
  end

  describe '.print_html_list' do
    let(:links) { %w( one two three ) }
    let(:list) { helper.print_html_list('mylist', links).to_s }
    let(:html_list) { HTML::Document.new(list).root }
    it 'lists all the links as a list' do
      links.each do |link|
        expect(list).to include link
      end
    end
    it 'includes a first/last class on the first/last element' do
      assert_select html_list, 'li' do |tags|
        expect(tags.first['class']).to include 'first'
        expect(tags.last['class']).to include 'last'
      end
    end
    it 'includes a the input class on all elements' do
      assert_select html_list, 'li.mylist', :count => links.length
    end

  end

  describe '.queryencode' do
    it 'encodes queries' do
      q = helper.html_queryencode({:this => 'whatever', :that => 'with a space'})
      expect(q).to eql '?this=whatever&that=with+a+space'
    end
  end
end
