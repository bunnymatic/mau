class ApiError < StandardError; end

class ApiController < ActionController::Base
  
  ALLOWED_OBJECTS = [:media, :artists, :studios, :art_pieces].map(&:to_s)
  def index
    path_elements = params[:path]
    begin
      raise ApiError.new('Nothing to see here') if !path_elements || path_elements.empty?
      raise ApiError.new('Invalid request') if !(ALLOWED_OBJECTS.include? path_elements[0])
      
      obj_type = path_elements[0].to_s
      clz = obj_type.classify.constantize
      
      extra_scope = {'artists' => :active}
      json_args = { 
        'art_pieces' => {},
        'media' => {},
        'artists' => {:include => [:art_pieces, :artist_info]},
        'studios' => {:include => :artists} 
      }
      allowed_attrs = {
        'studios' => [:name, :street, :url],
        'media' => [],
        'artists' => [],
        'art_pieces' => []
      }
      dat = nil
      case path_elements.count
      when 1
        if extra_scope[obj_type]
          dat = clz.send(extra_scope[obj_type]).all
        else
          dat = clz.all
        end
      when 2
        if path_elements[1] == 'ids'
          dat = clz.all.map(&:id)
        else
          dat = clz.find(path_elements[1].to_i)
          if obj_type == 'art_pieces'
            # validate that art is owned by active artist
            raise ApiError.new('Nothing to see here') unless dat.artist && dat.artist.is_active?
          end
        end
      when 3
        # get parameter named element 2 from id in element 1
        prop = path_elements[2].to_sym
        raise ApiError.new('Invalid request') unless allowed_attrs[obj_type].include? prop
        data = clz.find(path_elements[1].to_i)
        dat = {prop => data.send(prop)}
        json_args[obj_type] = {}
      else
        raise ApiError.new('Invalid request')
      end
      render :json => dat.to_json(json_args[obj_type]) 
    rescue NameError, ApiError => ex
      msg = "(%s) %s" % [ex.class, ex.message]
      Rails.logger.error 'API Error: ' + msg
      render :json => {:status => 400, :message => "Error Accessing API: #{msg}"}, :status => 400
    rescue ActiveRecord::RecordNotFound => ex
      render :json => {:status => 400, :message => "Unable to find the record given #{params[:path]}"}
    end
  end

end
