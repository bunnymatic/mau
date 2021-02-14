namespace :stats do
  namespace :histogram do
    desc 'art piece titles'
    task art_piece_title: :environment do
      hist = StatsCalculator.new(ArtPiece.select(:title).map { |t| t.title.downcase.split(/\s+/).map(&:strip) }.flatten).histogram
      hist.sort.each do |k, v|
        puts "#{v}\t#{k}"
      end
    end
  end
end
