class WizardsController < ApplicationController

  include MarkdownUtils
  layout 'mau1col'

  before_filter :login_required, :except => [ :flaxart, :mau042012 ]
  before_filter :post_only, :only => [:flax_submit_check, :flax_submit]
  before_filter :artists_only, :except => [ :flaxart, :mau042012 ]

  def artists_only
    if current_user and !current_artist
      # fan login
      render_not_found({:message => 'Sorry, you need a full fledged Artist account to submit to this show.'})
    end
  end

  def mau042012

    page = 'show_submissions'
    section = 'spring2012'
    markdown_content = CmsDocument.find_by_page_and_section(page, section)
    
    @content = { 
      :page => page,
      :section => section,
    }
    if !markdown_content.nil?
      @content[:content] = markdown(markdown_content.article) 
      @content[:cmsid] = markdown_content.id
    end

    render :layout => 'mau2col'
  end

  def mau042012_entrythingy
  end

  def flaxart
    render :layout => 'mau2col'
  end

  
  def flax_eventthingy
  end

end
