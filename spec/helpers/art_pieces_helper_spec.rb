require 'spec_helper'

describe ArtPiecesHelper do
  include ArtPiecesHelper
  fixtures :art_pieces
  describe 'pagination' do
  end

  describe 'compute_actual_image_size' do
    describe 'for a horizontal piece' do
      before do
        @art_piece = art_pieces(:h1024w2048)
      end
      ['orig','original'].each do |sz|
        it "returns the original dimensions given '#{sz}'" do
          compute_actual_image_size(sz, @art_piece).should == [@art_piece.image_width, @art_piece.image_height]
        end
      end
      ['medium','std','m'].each do |sz|
        it "returns the medium size dimensions given '#{sz}'" do
          compute_actual_image_size(sz, @art_piece).should == [400, 400 * @art_piece.image_height / @art_piece.image_width]
        end
      end
      ['small','sm','s'].each do |sz|
        it "returns the small size dimensions given '#{sz}'" do
          compute_actual_image_size(sz, @art_piece).should == [200, 200 * @art_piece.image_height / @art_piece.image_width]
        end
      end
      ['thumbnail','thumb'].each do |sz|
        it "returns the thumbnail size dimensions given '#{sz}'" do
          compute_actual_image_size(sz, @art_piece).should == [100, 100 * @art_piece.image_height / @art_piece.image_width]
        end
      end
      ['large'].each do |sz|
        it "returns the large size dimensions given '#{sz}'" do
          compute_actual_image_size(sz, @art_piece).should == [800, 800 * @art_piece.image_height / @art_piece.image_width]
        end
      end
    end
    describe 'for a vertical piece' do        
      before do
        @art_piece = art_pieces(:not)
      end
      ['orig','original'].each do |sz|
        it "returns the original dimensions given '#{sz}'" do
          compute_actual_image_size(sz, @art_piece).should == [@art_piece.image_width, @art_piece.image_height]
        end
      end
      ['medium','std','m'].each do |sz|
        it "returns the medium size dimensions given '#{sz}'" do
          compute_actual_image_size(sz, @art_piece).should == [400 * @art_piece.image_width / @art_piece.image_height, 400]
        end
      end
      ['small','sm','s'].each do |sz|
        it "returns the small size dimensions given '#{sz}'" do
          compute_actual_image_size(sz, @art_piece).should == [200 * @art_piece.image_width / @art_piece.image_height, 200]
        end
      end
      ['thumbnail','thumb'].each do |sz|
        it "returns the thumbnail size dimensions given '#{sz}'" do
          compute_actual_image_size(sz, @art_piece).should == [100 * @art_piece.image_width / @art_piece.image_height, 100]
        end
      end
      ['large'].each do |sz|
        it "returns the large size dimensions given '#{sz}'" do
          compute_actual_image_size(sz, @art_piece).should == [800 * @art_piece.image_width / @art_piece.image_height, 800]
        end
      end
    end
  end
  
end
