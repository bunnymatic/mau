class MainController < ApplicationController
  layout 'application'

  def index
    @is_homepage = true
    @seed = Time.zone.now.to_i
  end

  def contact; end

  def sampler
    sampler = ArtSampler.new(seed: sampler_params[:seed],
                             offset: sampler_params[:offset],
                             number_of_images: sampler_params[:number_of_images])
    render partial: 'sampler_thumb', collection: sampler.pieces
  end

  def version
    render plain: @revision
  end

  def about
    @page_title = PageInfoService.title('About Us')
    @content = CmsDocument.packaged('main', 'about')
  end

  def status_page
    status = ServerStatus.run
    render json: status, status: :ok
  end

  def resources
    @page_title = PageInfoService.title('Open Studios')
    page = 'main'
    section = 'artist_resources'
    doc = CmsDocument.find_by(page: page, section: section)
    @content = {
      page: page,
      section: section,
    }
    render && return unless doc

    @content[:content] = MarkdownService.markdown(doc.article)
    @content[:cmsid] = doc.id
  end

  def venues
    @page_title = PageInfoService.title('Venues')
    page = 'venues'
    section = 'all'
    doc = CmsDocument.find_by(page: page, section: section)
    @content = {
      page: page,
      section: section,
    }
    render && return unless doc

    @content[:content] = MarkdownService.markdown(doc.article)
    @content[:cmsid] = doc.id

    # temporary venues endpoint until we actually add a real
    # controller/model behind it
  end

  def sitemap
    sitemap = <<~SITEMAP
      <?xml version="1.0" encoding="UTF-8"?>
      <urlset
            xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xsi:schemaLocation="http://www.sitemaps.org/schemas/sitemap/0.9
                  http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd">
      <url>
        <loc>http://www.missionartists.org/</loc>
        <lastmod>2011-03-18T03:07:54+00:00</lastmod>
      </url>
      <url>
        <loc>http://www.missionartists.org/artists</loc>
      </url>
      <url>
        <loc>http://www.missionartists.org/studios/</loc>
      </url>
      <url>
        <loc>http://www.missionartists.org/open_studios</loc>
      </url>
      </urlset>
    SITEMAP
    render xml: sitemap
  end

  private

  def sampler_params
    params.permit(:seed, :offset, :number_of_images)
  end
end
