# frozen_string_literal: true
require 'rails_helper'

describe SearchQuery do
  describe '#keywords' do
    subject { super().keywords }
    it { should be_empty }
  end

  describe '#mediums' do
    subject { super().mediums }
    it { should be_empty }
  end

  describe '#studios' do
    subject { super().studios }
    it { should be_empty }
  end

  describe '#os_flag' do
    subject { super().os_flag }
    it { should be_nil }
  end

  describe '#page' do
    subject { super().page }
    it { should eql 0}
  end

  describe '#mode' do
    subject { super().mode }
    it { should be_nil }
  end

  describe '#query' do
    subject { super().query }
    it { should be_blank }
  end

  describe '#per_page' do
    subject { super().per_page }
    it { should eql SearchQuery::PER_PAGE }
  end
end
