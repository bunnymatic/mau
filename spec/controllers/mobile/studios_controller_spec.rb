require 'spec_helper'

describe StudiosController do

  render_views

  let!(:artists) { FactoryGirl.create_list(:artist, 3, :with_studio) }
  let(:open_studios_event) { FactoryGirl.create(:open_studios_event) }
  let(:studio) { Artist.open_studios_participants.first.studio }
  before do
    # do mobile
    controller.stub(:is_mobile? => true)
    request.stub(:user_agent => IPHONE_USER_AGENT)
    Artist.active.each_with_index do |a, idx|
      a.update_os_participation open_studios_event.key, ((idx % 2) == 0)
      a.save!
    end
  end

  describe "index" do
    before do
      get :index
    end

    it_should_behave_like "a regular mobile page"
    it_should_behave_like "non-welcome mobile page"

    it "includes a link to each studio" do
      Studio.all.each do |s|
        if s.artists.active.count > 0
          url = studio_path(s)
          url += "/" unless /\/$/.match(url)
          assert_select("a[href=#{url}]", :match => s.name)
        end
      end
    end
  end

  describe "show" do
    before do
      Artist.any_instance.stub(:os_participation => { open_studios_event.key => true})
      get :show, "id" => studio
    end

    it_should_behave_like "a regular mobile page"
    it_should_behave_like "non-welcome mobile page"

    it "assigns a page title" do
      assigns(:page_title).should eql "Studio: #{studio.name}"
    end

    it "includes studio title" do
      assert_select 'h2', /#{studio.name}/
    end
    it "includes studio address" do
      assert_select '.address', /#{studio.street}/
    end

    it "includes list of artists in that studio" do
      assert_select("li .thumb", :minimum => studio.artists.active.select{|a| a.representative_piece}.count)
    end

    it "includes the number of open studios participants" do
      n = studio.artists.open_studios_participants.count
      assert_select '.participants', /Open Studios Participants: #{n}/
    end

  end

end
