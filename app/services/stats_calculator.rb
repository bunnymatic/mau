class StatsCalculator

  def self.histogram(data)
    new(data).histogram
  end

  def initialize(data)
    @data = data
  end

  def histogram
    hist = {}
    @data.map do |v|
      hist[v] ||= 0
      hist[v] += 1
    end
    Hash[hist.sort_by(&:last).reverse]
  end

end
