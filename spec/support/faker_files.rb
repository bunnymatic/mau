module Faker
  class Files
    FILE_EXTENSIONS = %w[.jpg .csv .txt .whatever].freeze
    class << self
      def file
        Faker::Lorem.word + FILE_EXTENSIONS.sample
      end

      def file_with_path
        dir + file
      end

      def dir(depth = nil)
        depth ||= rand(1..2)
        Array.new(depth) { Faker::Lorem.word }.join('/')
      end
    end
  end
end
