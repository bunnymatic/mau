require 'fastercsv'
class CatalogController < ApplicationController
  include MarkdownUtils
  layout 'catalog'
  def index
    all_artists = Artist.active.open_studios_participants.partition{|a| (a.studio_id.nil? || a.studio_id == 0)}
    @indy_artists = all_artists[0].reject{|a| a.street.blank?}.sort &Artist.sort_by_lastname
    group_studio_artists = all_artists[1]
    # organize artists so they are in a tree 
    # [ [ studio_id, [artist1, artist2]], [studio_id2, [artist3, artist4]]]
    # so where studio_ids are in order of studio sort_by_name
    @studio_order = (group_studio_artists.map(&:studio).uniq.sort &Studio.sort_by_name).map{|s| s ? s.id : 0}
    @group_studio_artists = group_studio_artists.each_with_object({}) do |a,hsh|
      studio_id = a.studio_id || 0
      hsh[studio_id] = [] unless hsh[studio_id]
      hsh[studio_id] << a
    end
    @group_studio_artists.values.each do |artists| 
      artists.sort! &Artist.sort_by_lastname
    end

    page = 'main_openstudios'
    section = 'preview_reception'
    @preview_reception_html = CmsDocument.packaged(page, section)
        
    page = 'spring_2011_catalog'
    section = 'thanks'
    markdown_content = CmsDocument.find_by_page_and_section(page, section)
    @thanks = (markdown_content ? markdown(markdown_content.article) : '')

    respond_to do |format|
      format.html # index.html.erb
      format.json  { render :json => 'this' }
      format.csv {
        render_csv :filename => 'mau_os_artists_%s' % (Conf.oslive.to_s || '') do |csv|
          csv << ["First Name","Last Name","Full Name","Email", "Group Site Name","Studio Address","Studio Number","Cross Street 1","Cross Street 2","Primary Medium"]
          [@indy_artists, @group_studio_artists.values].flatten.sort(&Artist.sort_by_lastname).each do |artist|

            csv << [ artist.firstname, artist.lastname, artist.get_name, artist.email, artist.studio ? artist.studio.name : '', artist.address_hash[:parsed][:street], artist.studionumber, '', '', artist.primary_medium ? artist.primary_medium.name : '' ]
          end
        end
      }
    end
  end

end
