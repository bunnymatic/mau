class MainController < ApplicationController
  layout 'application'

  include MainHelper
  skip_before_filter :verify_authenticity_token, :only => [:getinvolved]

  def index
    @is_homepage = true
    @seed = Time.zone.now.to_i
  end

  def contact
  end

  def faq
  end

  def sampler
    sampler = ArtSampler.new sampler_params
    render partial: 'sampler_thumb', collection: sampler.pieces
  end

  def version
    render :text => @revision
  end

  def getinvolved
    @page_title = "Mission Artists United - Get Involved!"
    @page = params[:p]

    setup_paypal_flash_messages(@page)

    # handle feedback from the get involved page
    @feedback = Feedback.new
    if params[:commit]
      @feedback = Feedback.new(feedback_params)
      if @feedback.save
        FeedbackMailer.feedback(@feedback).deliver!
        flash.now[:notice] = "Thank you for your submission!  We'll get on it as soon as we can."
      else
        flash.now[:error] = "There was a problem submitting your feedback.<br/>" +
          @feedback.errors.full_messages.join("<br/>")
      end
    end
  end

  def about
    @page_title = "Mission Artists United - About Us"
    @content = CmsDocument.packaged('main','about')
  end

  def status_page
    # do dummy db test
    Medium.first
    render :json => {:success => true}, :status => 200
  end

  def notes_mailer
    f = FeedbackMail.new(feedback_mail_params.merge({:current_user => current_user}))
    data = {}
    if f.valid?
      f.save
      data = {success: true}
      status = 200
    else
      data = {
        success: false,
        error_messages: f.errors.full_messages
      }
      status = 400
    end
    render json: data, :status => status
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
      @content[:content] = MarkdownService.markdown(doc.article)
      @content[:cmsid] = doc.id
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
      @content[:content] = MarkdownService.markdown(doc.article)
      @content[:cmsid] = doc.id
    end

    # temporary venues endpoint until we actually add a real
    # controller/model behind it
  end

  # def non_mobile
  #   session[:mobile_view] = false
  #   ref = request.referer if is_local_referer?
  #   redirect_to ref || root_path
  # end

  # def mobile
  #   session[:mobile_view] = true
  #   ref = request.referer if is_local_referer?
  #   redirect_to ref || root_path
  # end


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

  private
  def setup_paypal_flash_messages(page)
    if page == 'paypal_success'
      flash.now[:notice] = "Thanks for your donation!  We'll spend it wisely."
    end
    if page == 'paypal_cancel'
      flash.now[:error] = "Did you have problems submitting your donation?"+
        " If so, please tell us with the feedback link at the bottom of the page."+
        " We'd love to know if the website or the PayPal connection is not working."
    end
  end

  def sampler_params
    params.slice(:seed, :offset, :number_of_images).symbolize_keys
  end
  
  def feedback_params
    params.require(:feedback).permit :subject, :email, :login, :page, :comment, :url, :skillsets, :bugtype
  end

  def feedback_mail_params
    params.require(:feedback_mail).permit :email, :email_confirm, :inquiry, :note_type, :os, :browser, :device, :version
  end
end
