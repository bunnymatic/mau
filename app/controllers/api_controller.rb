class ApiError < StandardError; end

class ApiController < ActionController::Base
  
  ALLOWED_OBJECTS = [:media, :artists, :studios, :art_pieces].map(&:to_s)
  def index
    path_elements = params[:path]
    begin
      raise ApiError.new(:message => 'Nothing to see here') if !path_elements || path_elements.empty?
      raise ApiError.new(:message => 'Invalid request') if !(ALLOWED_OBJECTS.include? path_elements[0])
      
      obj_type = path_elements[0]
      clz = obj_type.to_s.classify.constantize
      
      extra_scope = {'artists' => :active}
      json_args = { 
        'art_pieces' => {},
        'media' => {},
        'artists' => {:include => [:art_pieces, :artist_info]},
        'studios' => {:include => :artists} 
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
        dat = clz.find(path_elements[1])
      else
        raise ApiError.new(:message => 'Invalid request')
      end
      render :json => dat.to_json(json_args[obj_type.to_s]) 
    rescue NameError, ApiError => ex
      msg = "(%s) %s" % [ex.class, ex.message]
      RAILS_DEFAULT_LOGGER.error 'API Error: ' + msg
      render :json => {:status => 400, :message => "Error Accessing API: #{msg}"}, :status => 400
    rescue ActiveRecord::RecordNotFound => ex
      render :json => {:status => 400, :message => "Unable to find the record given #{params[:path]}"}
    end
  end

end
