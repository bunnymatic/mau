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
        @rand_pieces = get_random_pieces.map{|piece| ArtPiecePresenter.new(view_context,piece)}
      }
      format.json {
        @rand_pieces = get_random_pieces
        render :json => @rand_pieces.to_json
      }
      format.mobile { render :layout => 'mobile_welcome' }
    end
  end

  def contact
  end

  def faq
  end

  def sampler
    @rand_pieces = get_random_pieces.map{|piece| ArtPiecePresenter.new(view_context,piece)}
    render :partial => '/art_pieces/thumbs', :locals => {:pieces => @rand_pieces, :params => { :cols => 5 }}
  end

  def version
    render :text => [@revision, @build].join(' ')
  end

  # how many images do we need for the front page?
  @@NUM_IMAGES = 15
  def get_random_pieces(num_images=@@NUM_IMAGES)
    # get random set of art pieces and draw them
    ArtPiece.includes(:artist).where("users.state" => :active).order('rand()').sample(num_images)
  end

  def getinvolved
    @page_title = "Mission Artists United - Get Involved!"
    @page = params[:p]

    if @page == 'paypal_success'
      flash.now[:notice] = "Thanks for your donation!  We'll spend it wisely."
    end
    if @page == 'paypal_cancel'
      flash.now[:error] = "Did you have problems submitting your donation?"+
        " If so, please tell us with the feedback link at the bottom of the page."+
        " We'd love to know if the website or the PayPal connection is not working."
    end

    # handle feedback from the get involved page
    @feedback = Feedback.new
    if params[:commit]
      @feedback = Feedback.new(params[:feedback])
      if @feedback.valid?
        @feedback.save
        FeedbackMailer.feedback(@feedback).deliver!
        flash.now[:notice] = "Thank you for your submission!  We'll get on it as soon as we can."
      else
        flash.now[:error] = "There was a problem submitting your feedback.<br/>" +
          @feedback.errors.full_messages.join("<br/>")
      end
    end
  end

  def open_studios
    @page_title = "Mission Artists United: Spring Open Studios"

    @presenter = OpenStudiosPresenter.new

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

  def status_page
    # do dummy db test
    Medium.first
    render :json => {:success => true}, :status => 200
  end

  def notes_mailer
    if !request.xhr?
      render_not_found("Method Unavaliable")
      return
    end
    f = FeedbackMail.new( (params[:feedback_mail] ||{}).merge({:current_user => current_user}))
    status = 400
    if f.valid?
      f.save
      status = 200
    end
    render :json => f.to_json, :status => status
  end

  def news
    redirect_to 'resources'
  end

  def resources

    @page_title = "Mission Artists United - Open Studios"
    page = 'main'
    section = 'artist_resources'
    doc = CmsDocument.where(:page => page, :section => section).first
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
    doc = CmsDocument.where(:page => page, :section => section).first
    @content = {
      :page => page,
      :section => section
    }
    if doc
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
  <loc>http://www.missionartistsunited.org/main/open_studios</loc>
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

end
