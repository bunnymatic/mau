class WizardsController < ApplicationController

  layout 'mau1col'   

  before_filter :login_required, :except => [ :flaxart ]
  before_filter :post_only, :only => [:flax_submit_check, :flax_submit]
  
  def post_only 
    if !request.post?
      redirect_to flaxartchooser_path
      return
    end
  end

  def flaxart
    render :layout => 'mau2col'
  end
  
  def flax_chooser
  end

  def flax_submit_check
    # process post results
    art = params[:art]
    if art.blank? || !art.has_value?('1')
      flash[:error] = "You need to choose some art pieces."
      redirect_to flaxartchooser_path
      return 
    end
    selected = art.select{ |k,v| v == '1' }.map(&:first).map(&:to_i)
    @art_pieces = current_user.art_pieces.select{|ap| selected.include? ap.id}
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
    
    FlaxArtSubmission.new(:user_id => current_user.id, :art_piece_ids => art_pieces.join("|")).save!
    # store this data away
    redirect_to flaxartpayment_path
  end

  def flax_payment
  end

  def flax_success
  end

end
