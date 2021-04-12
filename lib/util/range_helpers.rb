module RangeHelpers
  def self.overlap?(range_a, range_b)
    range_a.cover?(range_b.begin) || range_b.cover?(range_a.begin)
  end

  def self.merge(range_a, range_b)
    [range_a.min, range_b.min].min..[range_a.max, range_b.max].max
  end

  def self.merge_overlapping(overlapping_ranges)
    overlapping_ranges.sort_by(&:begin).inject([]) do |ranges, range|
      if !ranges.empty? && overlap?(ranges.last, range)
        ranges[0...-1] + [merge(ranges.last, range)]
      else
        ranges + [range]
      end
    end
  end
end
