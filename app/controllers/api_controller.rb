class ApiError < StandardError; end

class ApiController < ActionController::Base

  ALLOWED_OBJECTS = [:media, :artists, :studios, :art_pieces].map(&:to_s)

  def index

    begin
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
        raise ApiError.new('Invalid request (V1)')
      end
      render json: dat.to_json(json_args[@obj_type])
    rescue NameError, ApiError => ex
      msg = "(%s) %s" % [ex.class, ex.message]
      Rails.logger.error 'API Error: ' + msg
      render json: {status: 400, message: "Error Accessing API: #{msg}"}, status: 400
    rescue ActiveRecord::RecordNotFound => ex
      render json: {status: 400, message: "Unable to find the record given #{params[:path]}"}
    end
  end

  private
  def path_elements
    @path_elements ||=
      begin
        raise ApiError.new('Nothing to see here') unless params[:path].present?
        path_elements = (params[:path].is_a? Array) ? params[:path] : (params[:path].split '/')
        raise ApiError.new('Invalid request (V1) Query is not allowed') if !(ALLOWED_OBJECTS.include? path_elements[0])
        path_elements
      end
  end

  def fetch_parameter(obj_id, prop)
    # get parameter named element 2 from id in element 1
    raise ApiError.new('Invalid request (V2)') unless allowed_property(prop)
    data = @clz.find(obj_id)
    {prop => data.send(prop)}
  end

  def fetch_ids(_id)
    if _id == 'ids'
      dat = fetch_all.map(&:id)
    else
      dat = @clz.find(_id.to_i)
      if @obj_type == 'art_pieces'
        # validate that art is owned by active artist
        raise ApiError.new('Nothing to see here') unless (dat.artist.present? && dat.artist.active?)
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
      'art_pieces' => {methods: [:photo]},
      'media' => {},
      'artists' => {
        except:
          [
            :created_at,
            :updated_at,
            :activated_at,
            :activation_code,
            :state,
            :crypted_password,
            :current_login_ip,
            :deleted_at,
            :email_attrs,
            :last_login_ip,
            :login_count,
            :last_request_at,
            :last_login_at,
            :current_login_at,
            :mailchimp_subscribed_at,
            :password_salt,
            :persistence_token,
            :photo_updated_at,
            :photo_content_type,
            :photo_file_size,
            :photo_updated_at
          ],
        include: {
          artist_info: {
            except: [
              :artist_id,
              :created_at,
              :updated_at,
              :description,
              :max_pieces,
              :news,
              :open_studios_participation,
              :lat,
              :lng,
              :addr_state,
              :addr_city,
              :zip
            ]
          },
          art_pieces: {
            methods: [:photo, :filename],
            except: [
              :created_at,
              :updated_at,
              :artist_id,
              :created_at,
              :updated_at,
              :description,
              :photo_updated_at,
              :photo_content_type,
              :photo_file_size,
              :photo_updated_at
            ]
          }
        },
        methods: [:photo]
      },
      'studios' => {
        include: :artists,
        except: [
          :created_at,
          :updated_at,
          :photo_updated_at,
          :photo_content_type,
          :photo_file_size,
          :photo_updated_at
        ],
        methods: [
          :photo
        ]
      }
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
