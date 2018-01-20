# frozen_string_literal: true

class StatsCalculator
  class Histogram < Hash
    class ValueError < StandardError; end

    def initialize(hash = nil)
      raise ValueError, "#{hash.inspect} is not a valid histogram initalize (Hash required)" if hash.present? && !hash.is_a?(Hash)
      merge!(hash || {})
    end

    def add(val)
      raise ValueError, "#{val.inspect} is not a valid histogram element" if val.blank?
      self[val] = (self[val] || 0) + 1
    end

    def sort_by_value_reverse
      Histogram.new(Hash[sort_by(&:last).reverse])
    end

    def append(hist)
      hist.each do |k, v|
        self[k] = (self[k] || 0) + v
      end
    end
  end

  def self.histogram(data)
    new(data).histogram
  end

  def initialize(data)
    @data = data
  end

  def histogram
    hist = Histogram.new
    @data.each { |v| hist.add(v) }
    hist.sort_by_value_reverse
  end
end
