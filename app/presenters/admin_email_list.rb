require 'csv'
class AdminEmailList < ViewPresenter

  include OpenStudiosEventShim

  BASE_COLUMN_HEADERS = ["First Name","Last Name","Full Name", "Email Address", "Group Site Name"]

  attr_accessor :list_names

  def initialize(list_names)
    @list_names = [list_names].flatten.map(&:to_s)
  end

  def csv_filename
    @csv_filename ||= (['email'] + list_names).compact.uniq.join("_") + ".csv"
  end

  def artists
    @artists ||= (is_multiple_os_query? ? os_participants : artists_by_list) || []
  end

  def emails
    @emails ||= artists.select{|a| a.email.present?}.map do |a|
      OpenStruct.new(
        {
          id: a.id,
          name: a.get_name,
          email: a.email,
          activated_at: a.activated_at,
          last_login: a.last_login_at.try(:to_formatted_s,:admin),
          link: url_helpers.artist_path(a.slug)
        }
      )
    end
  end

  def display_title
    @display_title ||= "#{title} [#{artists.length}]"
  end

  def title
    @title ||= (list_names.map{|n| titles[n.to_s]}.join ", ")
  end

  def os_participants
    @os_participants ||=
      begin
        artist_list = queried_os_tags.map do |tag|
          Artist.active.open_studios_participants(tag)
        end
        inlist = artist_list.shift
        artist_list.each do |l|
          inlist = inlist | l
        end
        inlist
      end
  end

  def csv
    @csv ||=
      begin
        csv_data = CSV.generate(DEFAULT_CSV_OPTS) do |_csv|
          _csv << csv_headers
          artists.each do |artist|
            _csv << artist_as_csv_row(artist)
          end
        end
      end
  end

  def artists_by_list
    list_name = list_names.first
    case list_name
    when 'fans'
      MauFan.all
    when *available_open_studios_keys
      Artist.active.open_studios_participants(list_name)
    when 'all'
      Artist.all
    when 'active', 'pending'
      Artist.send(list_names.first).all
    when 'no_profile'
      Artist.active.where("profile_image is null")
    when 'no_images'
      Artist.active.reject{|a| a.art_pieces.count > 0}
    end
  end

  def lists
    @lists ||=
      begin
        os_lists = available_open_studios_keys.reverse.map do |ostag|
          [ ostag, OpenStudiosEventService.for_display(ostag) ]
        end

        [[ "all", 'Artists'],
         [ "active", 'Activated'],
         [ "pending", 'Pending'],
         [ "fans", 'Fans' ],
         [ "no_profile", 'Active with no profile image'],
         [ "no_images", 'Active with no art']
        ] + os_lists
      end
  end

  private
  def titles
    @titles ||= Hash[lists]
  end


  def queried_os_tags
    @queried_os_tags ||= (list_names & available_open_studios_keys)
  end

  def is_multiple_os_query?
    @is_os_list ||= (list_names.length > 1) && (queried_os_tags.length > 1)
  end

  def csv_headers
    @csv_headers ||= BASE_COLUMN_HEADERS + available_open_studios_keys
  end

  def artist_as_csv_row(artist)
    [
     csv_safe(artist.firstname),
     csv_safe(artist.lastname),
     artist.get_name(false),
     artist.email,
     artist.studio ? artist.studio.name : ''
    ] + available_open_studios_keys.map do |os_tag|
      ((artist.respond_to? :os_participation) && artist.os_participation[os_tag]).to_s
    end
  end


end
