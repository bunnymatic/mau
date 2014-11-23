require 'pp'
namespace :debug do

  desc 'compute average aspect ratio'
  task :average_aspect_ratio => [:environment] do
    landscape = []
    portrait = []
    ArtPiece.find_each do |art_piece|
      if art_piece.artist.try(:active?)
        if art_piece.portrait?
          portrait << art_piece
        else
          landscape << art_piece
        end
      end
    end

    landscape_ratios = landscape.map(&:aspect_ratio).compact
    portrait_ratios = portrait.map(&:aspect_ratio).compact

    pp landscape_ratios.inject(&:+)/landscape_ratios.length.to_f if landscape_ratios.present?
    pp portrait_ratios.inject(&:+)/portrait_ratios.length.to_f if portrait_ratios.present?

  end
end
