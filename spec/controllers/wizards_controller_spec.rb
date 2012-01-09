require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

include AuthenticatedTestHelper

describe WizardsController do

  fixtures :users
  fixtures :artist_infos
  fixtures :art_pieces

  integrate_views

  it "actions should fail if not logged in" do
    exceptions = [:flaxart]
    controller_actions_should_fail_if_not_logged_in(:wizard,
                                                    :except => exceptions)
  end

  describe 'flaxart' do
    it "returns success" do
      get :flaxart
      response.should be_success
    end
  end

  [ :flax_chooser, :flax_payment, :flax_success ].each do |method|
    describe 'as a logged in fan hitting '+method.to_s do
      before do
        u = users(:maufan1)
        login_as(u)
        get method
      end
      it "returns success" do
        response.code.should == '404'
      end
      it "has error message" do
        response.should have_tag('div.oops')
      end
    end
  end

  describe "as logged in user" do
    before do 
      @u = users(:artist1)
      login_as(@u)
    end
    describe 'flax_chooser' do
      before do
        get :flax_chooser
      end
      it "returns success" do
        response.should be_success
      end
      it "displays all those art pieces" do
        @u.art_pieces.each do |ap|
          response.should have_tag('div.name', :text => ap.title)
        end
      end
      it 'has checkboxes for all the art and the os check' do
        response.should have_tag('input[type=checkbox]', :count => @u.art_pieces.length + 1)
      end
    end
    describe 'flax_submit_check' do
      it "fails on get" do
        get :flax_submit_check
        response.should redirect_to(flaxartchooser_path)
      end
      context "post" do
        context "no data" do
          before do
            post :flax_submit_check
          end
          it "redirects to chooser" do
            response.should redirect_to(flaxartchooser_path)
          end
          it "sets error flash" do
            flash[:error].should match(/choose/)
          end
        end
        context "no selected art" do
          before do
            post :flax_submit_check, {'12'=>'0', '13'=>'0'}
          end
          it "redirects to chooser" do
            response.should redirect_to(flaxartchooser_path)
          end
          it "sets error flash" do
            flash[:error].should match(/choose/)
          end
        end
        context "with data" do
          before do
            ai = @u.artist_info
            ai.os_participation = {'201104' => false}
            ai.save
            @u.reload
            art = {}
            art[@u.art_pieces.first.id] = '1'
            art[@u.art_pieces.last.id] = '0'
            art[@u.art_pieces.second.id] = '1'
            postparams = {"artist"=>@u.id, "art"=>art, "spring201104" => 'on'}
            post :flax_submit_check, postparams
          end
          it "returns success" do
            response.should be_success
          end
          it "assigns art_pieces array" do
            assigns(:art_pieces).should have(2).items
          end
          it "has no checkboxes" do
            response.should_not have_tag('input[type=checkbox]')
          end
          it "sets the user's os participation status to true" do
            @u.os_participation['201104'].should == true
          end
        end
      end
    end
    describe 'flax_submit' do
      it "fails on get" do
        get :flax_submit
        response.should redirect_to(flaxartchooser_path)
      end
      context "post" do
        it "with no data, redirects to flaxart chooser" do
          post :flax_submit
          response.should redirect_to(flaxartchooser_path)
        end
        context "with good data" do
          before do
            @ap_data = {}
            @u.art_pieces.map(&:id).map(&:to_s)[0..1].each { |k| @ap_data[k]=k }
          end
          it "redirects to payment page" do
            post :flax_submit, :art => @ap_data
            response.should redirect_to(flaxartpayment_path)
          end
          it "saves a new flaxart submission object" do
            post :flax_submit, :art => @ap_data
            results = FlaxArtSubmission.find_all_by_user_id(@u.id)
            results.length.should == 1
            results[0].art_piece_ids.should match /#{@u.art_pieces[0].id}/
            results[0].art_piece_ids.should match /#{@u.art_pieces[1].id}/
          end
          it "post twice saves the updated set of art pieces" do
            post :flax_submit, :art => @ap_data
            @ap_data = {}
            @u.art_pieces.map(&:id).map(&:to_s)[1..2].each { |k| @ap_data[k]=k }
            post :flax_submit, :art => @ap_data
            results = FlaxArtSubmission.find_all_by_user_id(@u.id)
            results.length.should == 1
            results[0].art_piece_ids.should == [@u.art_pieces[1].id, @u.art_pieces[2].id].join("|")
          end
        end
      end
      describe 'flax_payment' do
        it "returns success" do
          get :flax_payment
          response.should be_success
        end
        it "looks up the users submission" do
          FlaxArtSubmission.expects(:find_by_user_id).with(@u.id).once.returns(FlaxArtSubmission.new(:paid => true, :user_id => @u.id))
          get :flax_payment
        end
        describe 'user has paid' do
          before do
            FlaxArtSubmission.stubs(:find_by_user_id).returns(FlaxArtSubmission.new(:paid => true, :user_id => @u.id))
            get :flax_payment
          end
          it "if the user has paid it says so" do
            response.should have_tag('div.paid', :include => 'already paid')
          end
          it "has no paypal button" do
            response.should_not have_tag('form[action=https://www.paypal.com/cgi-bin/webscr]')
            response.should_not have_tag('input[name=submit]');
          end
        end
        it "if the user hasn't paid it has link to paypal" do
          FlaxArtSubmission.stubs(:find_by_user_id).returns(FlaxArtSubmission.new(:paid => false, :user_id => @u.id))
          get :flax_payment
          response.should have_tag('form[action=https://www.paypal.com/cgi-bin/webscr]')
          response.should have_tag('input[name=submit]');
        end
      end
    end
  end
end

