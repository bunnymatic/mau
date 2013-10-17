module Faker
  class Files
    FILE_EXTENSIONS = %w(.jpg .csv .txt .whatever)
    class << self
      def file
        Faker::Files.dir + Faker::Internet.domain_name + FILE_EXTENSIONS.sample
      end
      def dir
        rand(2).times.map{ Faker::Internet.domain_name }.join('/')
      end
    end
  end
end

