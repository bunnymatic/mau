class AdminEmailList

  include OsHelper

  attr_accessor :list_names

  def initialize(list_names)
    @list_names = [list_names].flatten.map(&:to_s)
  end

  def artists
    @artists ||= (is_multiple_os_query? ? os_participants : artists_by_list) || []
  end

  def emails
    artists.select{|a| a.email.present?}.map{|a| { :id => a.id, :name => a.get_name, :email => a.email }}
  end

  def display_title
    "#{title} [#{artists.length}]"
  end

  def title
    list_names.map{|n| titles[n.to_s]}.join ", "
  end

  def os_participants
    @os_participants ||= 
      begin
        queried_os_tags.map do |tag|
          Artist.active.open_studios_participants(tag)
        end.flatten.uniq
      end
  end

  def artists_by_list
    @artists_by_list ||=
      begin
        case list_names.first
        when 'fans'
          MAUFan.all
        when *os_tags
          Artist.active.open_studios_participants(list_names.first)
        when 'all'
          Artist.all
        when 'active', 'pending'
          Artist.send(list_names.first).all
        when 'no_profile'
          Artist.active.where("profile_image is null")
        when 'no_images'
          Artist.active.select{|a| a.art_pieces.count > 0}
        end
      end
  end

  def lists
    @lists ||=
      begin
        os_lists = os_tags.reverse.map do |ostag|
          [ ostag, os_pretty(ostag) ]
        end

        [[ "all", 'Artists'],
         [ "active", 'Activated'],
         [ "pending", 'Pending'],
         [ "fans", 'Fans' ],
         [ "no_profile", 'Active with no profile image'],
         [ "no_images", 'Active with no artwork']
        ] + os_lists
      end
  end

  private
  def titles
    @titles ||= Hash[lists]
  end

  def os_tags
    @os_tags ||= Conf.open_studios_event_keys.map(&:to_s)
  end

  def queried_os_tags
    @queried_os_tags ||= (list_names & os_tags)
  end

  def is_multiple_os_query?
    @is_os_list ||= (list_names.length > 1) && (queried_os_tags.length > 1)
  end

end
