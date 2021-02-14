module Enumerable
  def uniq_by
    h = {}
    inject([]) { |a, x| h[yield(x)] ||= a << x }
  end
end
