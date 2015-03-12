require 'spec_helper'

describe 'ArtistsController Routes' do
  describe 'member routes' do
    describe 'gets' do
      [:qrcode].each do |endpoint|
        it "routes #{endpoint} to the ArtistsController##{endpoint}" do
          { :get => "/artists/123/#{endpoint}" }.
            should route_to({:controller => 'artists', :id => '123', :action => endpoint.to_s})
        end
      end
    end
    describe 'posts' do
      [:notify_featured].each do |endpoint|
        it "routes #{endpoint} to the ArtistsController##{endpoint}" do
          { :post => "/artists/123/#{endpoint}" }.
            should route_to({:controller => 'artists', :id => '123', :action => endpoint.to_s})
        end
      end
    end
  end

  describe "- route generation" do
    it "should map controller artists, id 10 and action show to /artists/10" do
      (get '/artists/10').should route_to(:controller => "artists", :id => "10", :action => "show")
    end
    it "should map edit action properly" do
      (get '/artists/edit').should route_to(:controller => "artists", :action => "edit")
    end

    it "should map users/index to artists" do
      (get '/artists').should route_to(:controller => "artists", :action => "index")
    end
  end

  describe "- route recognition" do
    context "/artists/edit" do
      it "map get to artists controller edit method" do
        (get "/artists/edit").should route_to({:controller => "artists", :action => "edit" })
      end
    end
    context "/artists/10" do
      it "map PUT to update" do
        (put "/artists/10").should route_to({:controller => "artists", :action => "update", :id => "10" })
      end
      it "map GET to show" do
        (get "/artists/10").should route_to({:controller => "artists", :action => "show", :id => "10" })
      end
      it "map POST to update" do
        (post "/artists/10").should route_to({:controller => "artists", :action => 'update' , :id => '10'})
      end
      it "map DELETE /artists/10 as destroy" do

        (delete "/artists/10").should route_to({:controller => "artists", :action => "destroy", :id => "10" })
      end
    end
  end

end
