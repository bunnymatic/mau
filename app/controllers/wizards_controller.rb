class WizardsController < ApplicationController

  layout 'mau1col'

  before_filter :login_required, :except => [ :mau042012 ]
  before_filter :post_only, :only => [:flax_submit]
  before_filter :artists_only, :except => [ :mau042012 ]

  def artists_only
    if current_user and !current_artist
      # fan login
      render_not_found({:message => 'Sorry, you need a full fledged Artist account to submit to this show.'})
    end
  end

  def mau042012
    page = 'show_submissions'
    section = 'spring2012'
    @content = CmsDocument.packaged(page,section)
    render :layout => 'mau2col'
  end

  def mau042012_entrythingy
  end

end
