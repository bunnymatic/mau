# frozen_string_literal: true
require 'rails_helper'

describe HtmlHelper do
  describe '.print_html_list' do
    let(:links) { %w(one two three) }
    let(:list) { helper.print_html_list('mylist', links).to_s }
    let(:html_list) { Capybara::Node::Simple.new(list) }
    it 'lists all the links as a list' do
      links.each do |link|
        expect(list).to include link
      end
    end
    it 'includes a first/last class on the first/last element' do
      expect(html_list).to have_css('li')
      tags = html_list.all('li')
      expect(tags.first['class']).to include 'first'
      expect(tags.last['class']).to include 'last'
    end
    it 'includes a the input class on all elements' do
      expect(html_list).to have_css 'li.mylist', count: links.length
    end
  end
end
