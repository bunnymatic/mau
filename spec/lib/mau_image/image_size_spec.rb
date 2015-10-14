require 'spec_helper'


describe MauImage::ImageSize do

  describe '#all' do
    let(:all) { MauImage::ImageSize.all }

    it 'returns allowed image sizes with details' do
      all.should have(5).items
    end
  end

  describe '#find' do
    it 'finds the size you asked for' do
      MauImage::ImageSize.find(:original).name.should == 'original'
    end
  end

  describe '#height' do
    it 'returns height for small' do
      MauImage::ImageSize.find(:small).height.should eql 200
    end
    it 'returns height for l' do
      MauImage::ImageSize.find('l').height.should eql 800
    end
    it 'returns nil for orig' do
      MauImage::ImageSize.find('orig').height.should be_nil
    end
    it 'returns 400 for unknown' do
      MauImage::ImageSize.find('unk').height.should eql 400
    end
  end

  describe '#width' do
    it 'returns width for small' do
      MauImage::ImageSize.find(:small).width.should eql 200
    end
    it 'returns width for l' do
      MauImage::ImageSize.find('l').width.should eql 800
    end
    it 'returns nil for orig' do
      MauImage::ImageSize.find('orig').width.should be_nil
    end
    it 'returns 400 for unknown' do
      MauImage::ImageSize.find('unk').width.should eql 400
    end
  end

  describe '#keymap' do
    it 'returns medium given nothing' do
      MauImage::ImageSize.send(:keymap, nil).should eql :medium
      MauImage::ImageSize.send(:keymap, '').should eql :medium
    end
    it 'returns original for "orig"' do
      MauImage::ImageSize.send(:keymap, :orig).should eql :original
      MauImage::ImageSize.send(:keymap, 'orig').should eql :original
    end
    it 'returns thumb for thumbnail & thumb' do
      %w(thumb thumbnail).each do |sz|
        MauImage::ImageSize.send(:keymap, sz ).should eql :thumb
        MauImage::ImageSize.send(:keymap, sz.to_sym ).should eql :thumb
      end
    end
    it 'returns small for s or sm' do
      %w(s sm).each do |sz|
        MauImage::ImageSize.send(:keymap, sz).should eql :small
        MauImage::ImageSize.send(:keymap, sz.to_sym).should eql :small
      end
    end
    it 'returns large for l' do
      MauImage::ImageSize.send(:keymap, 'l' ).should eql :large
      MauImage::ImageSize.send(:keymap, :l ).should eql :large
    end
    it 'returns medium for m, med, standard, std or medium' do
      %w(m med standard std medium).each do |sz|
        MauImage::ImageSize.send(:keymap, sz).should eql :medium
      end
    end
    it 'returns the medium for something it doesn\'t recognize' do
      MauImage::ImageSize.send(:keymap, :blurp).should eql :medium
      MauImage::ImageSize.send(:keymap, 'blurp').should eql :medium
    end
  end
end
