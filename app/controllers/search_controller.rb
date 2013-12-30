def histogram inp; hash = Hash.new(0); inp.each {|k,v| hash[k]+=1}; hash; end

class SearchController < ApplicationController
  layout 'mau'

  @@CACHE_EXPIRY = (Conf.cache_expiry['search'] or 20)
  @@QUERY_KEY_PREFIX = "q:"
  PER_PAGE = 12

  def fetch
    execute_search
    render :layout => false
  end

  def index
    return unless execute_search
  end

  private

  def mediums_from_params
    mediums = []
    unless params[:medium].blank?
      medium_ids = params[:medium].values.map(&:to_i).reject{|v| v <= 0}
      mediums = Medium.by_name.where(:id => medium_ids)
    end
    mediums
  end

  def studios_from_params
    studios = []
    unless params[:studio].blank?
      studio_ids = params[:studio].values().compact.map(&:to_i)
      if (studio_ids && !studio_ids.empty?)
        if studio_ids.include? 0
          studios << Studio.indy
          studio_ids.reject!{|s| s == 0}
        end
        if !studio_ids.empty?
          studios += Studio.where(:id => studio_ids)
        end
      end
    end
    studios
  end

  def parse_search_params
    OpenStruct.new.tap do |opts|
      opts.keywords = (params[:keywords] || '').split(",").map(&:strip)

      opts.mediums = mediums_from_params
      opts.studios = studios_from_params

      opts.os_flag = { '1' => true, '2' => false }[params[:os_artist]]

      opts.page = params[:p].to_i

      opts.mode = params[:m]

      opts.query = opts.keywords.compact.join(", ")

      opts.per_page = (params[:per_page] || PER_PAGE).to_i
    end
  end

  PER_PAGE_OPTS = [12,24,48,96].freeze

  def per_page_options(results)
    @per_page_options ||= PER_PAGE_OPTS[0..PER_PAGE_OPTS.select{|v| v < results.count}.count]
  end

  def execute_search

    opts = parse_search_params

    results = MauSearch.new(opts).search

    @per_page_opts = per_page_options(results)
    opts.per_page = results.count < opts.per_page ? @per_page_opts.max : opts.per_page

    @paginator = Pagination.new(view_context, results, opts.page, opts.per_page)

    @per_page = opts.per_page
    @user_query = opts.query || ''
    @keywords = opts.keywords || []
    @mediums = opts.mediums || []
    @studios = opts.studios || []

  end

end
