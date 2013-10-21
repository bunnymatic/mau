module Faker
  class Files
    FILE_EXTENSIONS = %w(.jpg .csv .txt .whatever)
    class << self
      def file
        Faker::Lorem.word + FILE_EXTENSIONS.sample
      end
      def file_with_path
        dir + file
      end
      def dir(depth=nil)
        depth ||= 1+rand(2)
        depth.times.map{ Faker::Lorem.word }.join('/')
      end
    end
  end
end

