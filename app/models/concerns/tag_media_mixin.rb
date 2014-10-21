module TagMediaMixin
  extend ActiveSupport::Concern
  include HtmlHelper

  def safe_name
    html_encode(self.name).gsub(' ', '&nbsp;').html_safe
  end

  module ClassMethods
    def normalize(arr, fld)
      maxct = get_max_value(arr,fld)
      maxct = 1.0 if !maxct || maxct <=0
      arr.map do |m|
        m[fld] = m[fld].to_f / maxct.to_f
        m
      end
    end

    def get_max_value(arr,fld)
      arr.map{|m| m[fld].to_i}.max.to_f
    end

    def flush_cache
      SafeCache.delete cache_key(true)
      SafeCache.delete cache_key(false)
    end
  end
  
end