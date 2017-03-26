# frozen_string_literal: true
class PaginationError < StandardError; end

class Pagination < ViewPresenter
  attr_reader :per_page

  def initialize(array, current, per_page, opts = nil)
    raise PaginationError, 'per_page must be present and greater than 0' unless per_page && per_page.to_i.positive?
    @array = array
    @current = current
    @per_page = [per_page, 1].max
    opts ||= {}
    @previous_label = opts[:previous_label]
    @previous_title = opts[:previous_title]
    @next_label = opts[:next_label]
    @next_title = opts[:next_title]
  end

  def should_paginate?
    last_page > first_page
  end

  def count
    @count ||= (@array || []).length
  end

  def current_page?(page)
    page.to_i == @current.to_i
  end

  def display_current_position
    "page #{current_page + 1} of #{last_page + 1}"
  end

  def last_page
    @last_page ||= ((count.to_f - 1.0) / per_page.to_f).floor.to_i
    @last_page = 0 if @last_page.negative?
    @last_page
  end

  def current_page
    @current_page ||= @current.to_i
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
    current_page * per_page
  end

  def last_item
    first_item + (per_page - 1)
  end

  def pages
    first_page..last_page
  end

  def items
    (@array || [])[first_item..last_item] || []
  end

  def previous_link?
    current_page > first_page
  end

  def next_link?
    current_page < last_page
  end

  alias more? next_link?

  def previous_title
    @previous_title || 'previous'
  end

  def link_to_page(page)
    unless respond_to? :page_link
      raise PaginationError, 'link_to_page requires page_link to be defined!'
    end
    link_to page + 1, page_link(page), title: page + 1
  end

  def link_to_previous
    unless respond_to? :previous_link
      raise PaginationError, 'link_to_previous requires previous_link to be defined!'
    end
    link_to previous_label, previous_link, title: previous_title
  end

  def link_to_next
    raise PaginationError, 'link_to_next requires next_link to be defined!' unless respond_to? :next_link
    link_to next_label, next_link, title: next_title
  end

  def previous_label
    raw(@previous_label || '&lt;prev')
  end

  def next_title
    @next_title || 'next'
  end

  def next_label
    raw(@next_label || 'next&gt;')
  end
end
