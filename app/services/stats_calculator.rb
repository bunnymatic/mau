class StatsCalculator

  def self.histogram(data)
    new(data).histogram
  end
  
  def initialize(data)
    @data = data
  end

  def histogram
    Hash.new(0).tap do |hash|
      @data.each {|v| hash[v]+=1}
    end
  end
  
end

