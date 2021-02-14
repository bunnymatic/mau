require 'rails_helper'

describe MauImage::ImageSize do
  describe '#all' do
    let(:all) { MauImage::ImageSize.all }

    it 'returns allowed image sizes with details' do
      expect(all.size).to eq(5)
    end
  end

  describe '#find' do
    it 'finds the size you asked for' do
      expect(MauImage::ImageSize.find(:original).name).to eq('original')
    end
  end

  describe '#height' do
    it 'returns height for small' do
      expect(MauImage::ImageSize.find(:small).height).to eql 200
    end
    it 'returns height for l' do
      expect(MauImage::ImageSize.find('l').height).to eql 800
    end
    it 'returns nil for orig' do
      expect(MauImage::ImageSize.find('orig').height).to be_nil
    end
    it 'returns 400 for unknown' do
      expect(MauImage::ImageSize.find('unk').height).to eql 400
    end
  end

  describe '#width' do
    it 'returns width for small' do
      expect(MauImage::ImageSize.find(:small).width).to eql 200
    end
    it 'returns width for l' do
      expect(MauImage::ImageSize.find('l').width).to eql 800
    end
    it 'returns nil for orig' do
      expect(MauImage::ImageSize.find('orig').width).to be_nil
    end
    it 'returns 400 for unknown' do
      expect(MauImage::ImageSize.find('unk').width).to eql 400
    end
  end

  describe '#keymap' do
    it 'returns medium given nothing' do
      expect(MauImage::ImageSize.send(:keymap, nil)).to eql :medium
      expect(MauImage::ImageSize.send(:keymap, '')).to eql :medium
    end
    it 'returns original for "orig"' do
      expect(MauImage::ImageSize.send(:keymap, :orig)).to eql :original
      expect(MauImage::ImageSize.send(:keymap, 'orig')).to eql :original
    end
    it 'returns thumb for thumbnail & thumb' do
      %w[thumb thumbnail].each do |sz|
        expect(MauImage::ImageSize.send(:keymap, sz)).to eql :thumb
        expect(MauImage::ImageSize.send(:keymap, sz.to_sym)).to eql :thumb
      end
    end
    it 'returns small for s or sm' do
      %w[s sm].each do |sz|
        expect(MauImage::ImageSize.send(:keymap, sz)).to eql :small
        expect(MauImage::ImageSize.send(:keymap, sz.to_sym)).to eql :small
      end
    end
    it 'returns large for l' do
      expect(MauImage::ImageSize.send(:keymap, 'l')).to eql :large
      expect(MauImage::ImageSize.send(:keymap, :l)).to eql :large
    end
    it 'returns medium for m, med, standard, std or medium' do
      %w[m med standard std medium].each do |sz|
        expect(MauImage::ImageSize.send(:keymap, sz)).to eql :medium
      end
    end
    it 'returns the medium for something it doesn\'t recognize' do
      expect(MauImage::ImageSize.send(:keymap, :blurp)).to eql :medium
      expect(MauImage::ImageSize.send(:keymap, 'blurp')).to eql :medium
    end
  end
end
