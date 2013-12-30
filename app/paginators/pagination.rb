class PaginationError < StandardError; end

class Pagination

  def initialize(array, current, per_page)
    raise PaginationError.new("per_page must be present and greater than 0") unless per_page && (per_page.to_i > 0)

    @array = array
    @current = current
    @per_page = [per_page,1].max
  end

  def should_paginate?
    last_page > first_page
  end

  def count
    @count ||= (@array||[]).length
  end

  # currently unused, but it seems like it might come in handy
  # 
  #def display_current_position
  #  "page #{current_page + 1} of #{last_page + 1}"
  #end

  def last_page
    @last_page ||= ((count.to_f-1.0) / @per_page.to_f).floor.to_i
    @last_page = 0 if @last_page < 0
    @last_page
  end

  def current_page
    unless @current_page
      @current_page = [[@current.to_i, 0].max, last_page].min
    end
    @current_page
  end

  def next_page
    [current_page + 1, last_page].min
  end

  def previous_page
    [current_page - 1, first_page].max
  end

  def first_page
    0
  end

  def first_item
    current_page * @per_page
  end

  def last_item
    first_item + (@per_page - 1)
  end

  def items
    @array[first_item..last_item]
  end

  def previous_link?
    current_page != first_page
  end

  def next_link?
    current_page != last_page
  end


end
