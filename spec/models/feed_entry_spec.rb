require 'rails_helper'

describe MauFeed::Entry do

  let(:source_url) { 'http://wordpress.com' }
  let(:the_time) { Time.zone.now }
  let(:description) { '<div>the <img src="img.jpg"/> <br/> description  </div>   ' }
  let(:title) { '<div>the <h2>title  </h2>  </div>   ' }
  let(:raw_entry) { OpenStruct.new(:title => title, :description => description, :date => the_time) }
  let(:trunc) { false }
  let(:clean_desc) { true }
  subject(:entry) { MauFeed::Entry.new(raw_entry, source_url, clean_desc, trunc) }

  describe '#title' do
    subject { super().title }
    it { should eql title.strip }
  end

  describe '#description' do
    subject { super().description }
    it { should eql 'the     description' }
  end

  describe '#date' do
    subject { super().date }
    it { should eql the_time }
  end

  context 'when clean_desc is false' do
    let(:clean_desc) { false }

    describe '#description' do
      subject { super().description }
      it { should eql description.strip }
    end
  end

  context 'when truncate is true' do
    let(:trunc) { true }

    context 'and it has a long title' do
      let(:title) { Faker::Lorem.words(70).join(" ") }
      it 'truncates the title' do
        expect(subject.title.size).to eq(MauFeed::Entry::TITLE_LENGTH)
      end
    end

    context 'and the description is really long' do
      let(:description) { Faker::Lorem.words(300).join(" ") }
      it 'truncates the description' do
        expect(subject.description.size).to eq(MauFeed::Entry::DESCRIPTION_LENGTH)
      end
    end

  end

end
