module SearchHelper

  # assumes current and last is related to index 0
  def get_pages_for_pagination current, num_pages
    pages = []
    current = current.to_i
    last = num_pages.to_i - 1
    3.times do |ii|
      pages << ii
      pages << last - ii
    end
    3.times do |ii|
      pages << current - ii + 1 # +1 for 1/2 of 3
    end

    pages.sort.uniq.select{|x| x <= last && x >= 0 }
  end

end
