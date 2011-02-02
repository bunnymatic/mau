class WizardsController < ApplicationController

  layout 'mau1col'

  before_filter :login_required, :except => [ :flaxart ]
  before_filter :post_only, :only => [:flax_submit_check, :flax_submit]
  before_filter :artists_only, :except => [ :flaxart ]

  def post_only 
    if !request.post?
      redirect_to flaxartchooser_path
      return
    end
  end
  def artists_only
    if current_user and !current_artist
      # fan login
      render_not_found({:message => 'Sorry, you need a full fledged Artist account to submit to this show.'})
    end
  end

  def flaxart
    render :layout => 'mau2col'
  end
  
  def flax_chooser
    render :layout => 'mau'
  end

  def flax_submit_check
    # process post results
    art = params[:art]
    if art.blank? || !art.has_value?('1')
      flash[:error] = "You need to choose some art pieces."
      redirect_to flaxartchooser_path
      return 
    end
    selected = art.select{ |k,v| v == '1' }.map(&:first).map(&:to_i)[0..2]
    @art_pieces = current_user.art_pieces.select{|ap| selected.include? ap.id}
    ai = current_user.artist_info
    if !ai.os_participation['201104']
      ai.os_participation = {'201104' => true}
      ai.save
    end
  end

  def flax_submit
    art = params[:art]
    if art.blank?
      flash[:error] = "You need to choose some art pieces."
      redirect_to flaxartchooser_path
      return 
    end
    selected = art.keys.map(&:to_i)
    if selected.size == 0
      flash[:error] = "You need to choose some art pieces."
      redirect_to flaxartchooser_path
      return 
    end
    art_pieces = current_user.art_pieces.select{|ap| selected.include? ap.id}.map(&:id)
    
    submission = FlaxArtSubmission.find_by_user_id(current_user.id)
    if submission.nil?
      submission = FlaxArtSubmission.new(:user_id => current_user.id)
    end
    submission.art_piece_ids = art_pieces.join("|")
    submission.save!
    # store this data away
    
    cookies[:mau_flaxsubmission] = {:value => CookiesHelper::encode_cookie({ :submission => submission.id,
                                                                             :submitted => Time.now() }),
                                    :expires => 1.day.from_now }

    redirect_to flaxartpayment_path
  end

  def flax_payment
    submission = FlaxArtSubmission.find_by_user_id(current_user.id)
    unless submission.nil? 
      if submission.paid
        @paid = true
      end
    end
  end

  def flax_payment_cancel
  end

  def flax_success
    cookie = CookiesHelper::decode_cookie(cookies[:mau_flaxsubmission])
    if !cookie
      raise "Waited too long?"
    end
    if (cookie["submission"])
      # it's from paypal
      @submission = FlaxArtSubmission.find(cookie["submission"].to_i)
      @submission.paid = true
      @submission.save!
      @submission.reload
    end
    render :layout => 'mau2col'
  end
end
