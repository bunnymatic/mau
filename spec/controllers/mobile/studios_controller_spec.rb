require 'spec_helper'

describe StudiosController do

  fixtures :studios
  fixtures :users, :artist_infos, :roles, :roles_users

  render_views

  before do
    # do mobile
    request.stub(:user_agent => IPHONE_USER_AGENT)
    assert(Studio.all.length >= 2)
    @s = Studio.all[2]
    Artist.active.each_with_index do |a, idx|
      a.update_os_participation Conf.oslive, ((idx % 2) == 0)
      a.studio = @s
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
      Artist.any_instance.stub(:representative_piece => nil, :os_participation => {Conf.oslive.to_s => true})
      get :show, :id => @s.id
    end

    it_should_behave_like "a regular mobile page"
    it_should_behave_like "non-welcome mobile page"

    it "includes studio title" do
      assert_select 'h2', /#{@s.name}/
    end
    it "includes studio address" do
      assert_select '.address', /#{@s.street}/
    end

    it "includes list of artists in that studio" do
      assert_select("li .thumb", :minimum => @s.artists.active.select{|a| a.representative_piece}.count)
    end

    it "includes the number of open studios participants" do
      n = @s.artists.open_studios_participants.count
      assert_select '.participants', /Open Studios Participants: #{n}/
    end

  end

end
