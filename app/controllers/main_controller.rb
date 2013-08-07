require 'rand_helpers'
require 'open-uri'
require 'rss/1.0'
require 'rss/2.0'

FEEDS_KEY = 'news-feeds'

class MainController < ApplicationController
  layout 'mau2col'
  include MarkdownUtils
  include MainHelper
  skip_before_filter :verify_authenticity_token, :only => [:getinvolved]
  before_filter :no_cache, :only => :index

  def index
    respond_to do |format|
      format.html {
        @is_homepage = true
        @rand_pieces = get_random_pieces
        render
      }
      format.json {
        @rand_pieces = get_random_pieces
        render :json => @rand_pieces.to_json(:include => [:artist])
      }
      format.mobile { render :layout => 'mobile_welcome' }
    end
  end

  def contact
  end

  def faq
  end

  def sampler
    @rand_pieces = get_random_pieces
    render :partial => '/art_pieces/thumbs', :locals => { :pieces => @rand_pieces, :params => { :cols => 5 }}
  end

  def version
    render :text => @@revision
  end

  # how many images do we need for the front page?
  @@NUM_IMAGES = 15
  def get_random_pieces(num_images=@@NUM_IMAGES)
    # get random set of art pieces and draw them
    @rand_pieces = []
    all = Artist.active.all(:include => :art_pieces).map(&:art_pieces).flatten
    numpieces = all.length
    if numpieces > num_images
      @rand_pieces = choice(all, num_images)
    else
      @rand_pieces = all
    end
  end

  def getinvolved
    @page_title = "Mission Artists United - Get Involved!"
    @page = params[:p]

    if @page == 'paypal_success'
      flash.now[:notice] = "Thanks for your donation!  We'll spend it wisely."
    end
    if @page == 'paypal_cancel'
      flash.now[:error] = "Did you have problems submitting your donation?  If so, please tell us with the feedback link at the bottom of the page.  We'd love to know if the website or the PayPal connection is not working."
    end

    if params[:commit]
      if params[:feedback][:email].empty?
        flash.now[:error] = "There was a problem submitting your feedback.  Your email was blank."
        return
      end
      if params[:feedback][:comment].empty?
        flash.now[:error] = "There was a problem submitting your feedback.  Please fill something in for the comment."
        return
      end

      feedback = Feedback.new(params[:feedback])
      saved = feedback.save
      if saved
        FeedbackMailer.feedback(feedback).deliver!
        flash.now[:notice] = "Thank you for your submission!  We'll get on it as soon as we can."
      else
        flash.now[:error] = "There was a problem submitting your feedback.  Was your comment empty?"
      end
    end
  end

  def openstudios
    @page_title = "Mission Artists United: Spring Open Studios"
    @participating_studios = Artist.active.open_studios_participants.reject{|a| a.studio_id == 0}.map(&:studio).compact.uniq.sort &Studio.sort_by_name
    @participating_indies = Artist.active.open_studios_participants.select{|a| a.studio_id == 0}.sort &Artist.sort_by_lastname

    page = 'main_openstudios'
    section = 'summary'

    @summary = CmsDocument.packaged(page,section)

    section = 'preview_reception'
    @preview_reception_html = CmsDocument.packaged(page, section)

    respond_to do |fmt|
      fmt.html { render }
      fmt.mobile {
        @page_title = "Spring Open Studios"
        render :layout => 'mobile'
      }
    end

  end

  def history
    @page_title = "Mission Artists United - History"
    @content = CmsDocument.packaged('main','history')
  end

  def about
    @page_title = "Mission Artists United - About Us"
    respond_to do |fmt|
      fmt.html {
        @content = CmsDocument.packaged('main','about')
        render
      }
      fmt.mobile {
        @page_title = "About Us"
        render :layout => 'mobile'
      }
    end
  end

  def status
    # do dummy db test
    Medium.first
    render :json => {:success => true}, :status => 200
  end

  def notes_mailer
    if !request.xhr?
      render_not_found("Method Unavaliable")
      return
    end
    resp_hash = MainController::validate_params(params)
    if resp_hash[:messages].size < 1
      # process
      email = params["email"] || ""
      subject = "MAU Submit Form : #{params["note_type"]}"
      login = "anon"
      if current_user
        login = current_user.login
        email += " (account email : #{current_user.email})"
      end
      comment = ''
      comment += "OS: #{params["operating_system"]}\n"
      comment += "Browser: #{params["browser"]}\n"
      case params["note_type"]
      when 'inquiry', 'help'
        comment += "From: #{email}\nQuestion: #{params['inquiry']}\n"
      when 'email_list'
        comment += "From: #{email}\n Add me to your email list\n"
      when 'feed_submission'
        comment += "Feed Link: #{params['feedlink']}\n"
      end

      f = Feedback.new( { :email => email,
                          :subject => subject,
                          :login => login,
                          :comment => comment })
      if f.save
        FeedbackMailer.feedback(f).deliver!
      end
    end
    render :json => resp_hash
  end

  def news
    redirect_to 'resources'
  end

  def resources

    @page_title = "Mission Artists United - Open Studios"
    page = 'main'
    section = 'artist_resources'
    doc = CmsDocument.find_by_page_and_section(page, section)
    @content = {
      :page => page,
      :section => section
    }
    if !doc.nil?
      @content[:content] = markdown(doc.article)
      @content[:cmsid] = doc.id
    end
    respond_to do |fmt|
      fmt.html{ render :action => 'resources', :layout => 'mau2col' }
      fmt.mobile { render :layout => 'mobile_welcome' }
    end
  end

  def venues
    @page_title = "Mission Artists United - Venues"
    page = 'venues'
    section = 'all'
    doc = CmsDocument.find_by_page_and_section(page, section)
    @content = {
      :page => page,
      :section => section
    }
    if !doc.nil?
      @content[:content] = markdown(doc.article)
      @content[:cmsid] = doc.id
    end

    # temporary venues endpoint until we actually add a real
    # controller/model behind it
  end

  def non_mobile
    session[:mobile_view] = false
    ref = request.referer if is_local_referer?
    redirect_to ref || root_path
  end

  def mobile
    session[:mobile_view] = true
    ref = request.referer if is_local_referer?
    redirect_to ref || root_path
  end


  def sitemap
    sitemap = <<EOM
<?xml version="1.0" encoding="UTF-8"?>
<urlset
      xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"
      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
      xsi:schemaLocation="http://www.sitemaps.org/schemas/sitemap/0.9
            http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd">
<url>
  <loc>http://www.missionartistsunited.org/</loc>
  <lastmod>2011-03-18T03:07:54+00:00</lastmod>
</url>
<url>
  <loc>http://www.missionartistsunited.org/artists</loc>
</url>
<url>
  <loc>http://www.missionartistsunited.org/studios/</loc>
</url>
<url>
  <loc>http://www.missionartistsunited.org/artists/map?osonly=1</loc>
</url>
<url>
  <loc>http://www.missionartistsunited.org/media</loc>
</url>
<url>
  <loc>http://www.missionartistsunited.org/main/openstudios</loc>
</url>
<url>
  <loc>http://www.missionartistsunited.org/getinvolved/</loc>
</url>
<url>
  <loc>http://www.missionartistsunited.org/about</loc>
</url>
</urlset>
EOM
    render :xml => sitemap
  end

  private
  def self.validate_params(params)
    results = { :status => 'success', :messages => [] }

    # common validation
    unless ["feed_submission", "help", "inquiry", "email_list"].include? params[:note_type]
      results[:messages] << "invalid note type"
    else
      if !(['feed_submission'].include? params[:note_type])
        ['email','email_confirm'].each do |k|
          if params[k].blank?
            humanized = ActiveSupport::Inflector.humanize(k)
            results[:messages] << "#{humanized} can't be blank"
          end
        end

        if (params.keys.select { |k| ['email', 'email_confirm' ].include? k }).size < 2
          results[:messages] << 'not enough parameters'
        end
        if params['email'] != params['email_confirm']
          results[:messages] << 'emails do not match'
        end
      elsif 'feed_submission' == params[:note_type]
        if (params.keys.select { |k| ['feedlink' ].include? k }).size < 1
          results[:messages] << 'not enough parameters'
        end
      end
      # specific
      case params[:note_type]
      when 'inquiry'
        if params['inquiry'].blank?
          results[:messages] << 'note cannot be empty'
          results[:messages] << 'not enough parameters'
        end
      when 'email_list'
      when 'feed_submission'
        if params["feedlink"].blank?
          results[:messages] << 'feed url can\'t be empty'
        end
      else
      end
    end
    if results[:messages].size > 0
      results[:status] = 'error'
    end
    results
  end
end
