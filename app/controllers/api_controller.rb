class ApiError < StandardError; end

class ApiController < ActionController::Base

  ALLOWED_OBJECTS = [:media, :artists, :studios, :art_pieces].map(&:to_s)

  def index

    begin
      raise ApiError.new('Nothing to see here') unless params[:path].present?

      path_elements = (params[:path].is_a? Array) ? params[:path] : (params[:path].split '/')

      raise ApiError.new('Invalid request') if !(ALLOWED_OBJECTS.include? path_elements[0])

      @obj_type = path_elements[0].to_s
      @clz = @obj_type.classify.constantize

      dat = nil
      case path_elements.count
      when 1
        dat = fetch_all
      when 2
        dat = fetch_ids path_elements[1]
      when 3
        dat = fetch_parameter path_elements[1], path_elements[2]
      else
        raise ApiError.new('Invalid request')
      end
      render :json => dat.to_json(json_args[@obj_type])
    rescue NameError, ApiError => ex
      msg = "(%s) %s" % [ex.class, ex.message]
      Rails.logger.error 'API Error: ' + msg
      render :json => {:status => 400, :message => "Error Accessing API: #{msg}"}, :status => 400
    rescue ActiveRecord::RecordNotFound => ex
      render :json => {:status => 400, :message => "Unable to find the record given #{params[:path]}"}
    end
  end

  private
  def fetch_parameter(obj_id, prop)
    # get parameter named element 2 from id in element 1
    raise ApiError.new('Invalid request') unless allowed_property(prop)
    data = @clz.find(obj_id.to_i)
    {prop => data.send(prop)}
  end

  def fetch_ids(_id)
    if _id == 'ids'
      dat = fetch_all.map(&:id)
    else
      dat = @clz.find(_id.to_i)
      if @obj_type == 'art_pieces'
        # validate that art is owned by active artist
        raise ApiError.new('Nothing to see here') unless (dat.artist.present? && dat.artist.is_active?)
      end
    end
    dat
  end

  def fetch_all
    if extra_scope[@obj_type]
      @clz.send(extra_scope[@obj_type]).all
    else
      @clz.all
    end
  end

  def allowed_property(prop)
    allowed_attrs[@obj_type].try(:include?,prop.to_sym)
  end

  def extra_scope
    @extra_scope ||= {
      'artists' => :active,
      'art_pieces' => :owned
    }.freeze
  end

  def json_args
    @json_args ||= {
      'art_pieces' => {},
      'media' => {},
      'artists' => {:include => [:art_pieces, :artist_info]},
      'studios' => {:include => :artists}
    }.freeze
  end

  def allowed_attrs
    @allowed_attrs ||= {
      'studios' => [:name, :street, :url],
      'media' => [],
      'artists' => [],
      'art_pieces' => []
    }.freeze
  end

end
