require 'spec_helper'

describe FeedEntry do

  let(:source_url) { 'http://wordpress.com' }
  let(:the_time) { Time.zone.now }
  let(:description) { '<div>the <img src="img.jpg"/> <br/> description  </div>   ' }
  let(:title) { '<div>the <h2>title  </h2>  </div>   ' }
  let(:raw_entry) { OpenStruct.new(:title => title, :description => description, :date => the_time) }
  let(:trunc) { false }
  let(:clean_desc) { true }
  subject(:entry) { FeedEntry.new(raw_entry, source_url, clean_desc, trunc) }

  its(:title) { should eql title.strip }
  its(:description) { should eql 'the     description' }
  its(:date) { should eql the_time }

  context 'when clean_desc is false' do
    let(:clean_desc) { false }
    its(:description) { should eql description.strip }
  end

  context 'when truncate is true' do
    let(:trunc) { true }

    context 'and it has a long title' do
      let(:title) { Faker::Lorem.words(70).join(" ") }
      it 'truncates the title' do
        expect(subject.title).to have(FeedEntry::TITLE_LENGTH).characters
      end
    end

    context 'and the description is really long' do
      let(:description) { Faker::Lorem.words(300).join(" ") }
      it 'truncates the description' do
        expect(subject.description).to have(FeedEntry::DESCRIPTION_LENGTH).characters
      end
    end

  end

end
