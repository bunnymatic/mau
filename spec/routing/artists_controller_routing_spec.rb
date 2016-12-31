require 'rails_helper'

describe 'ArtistsController Routes' do
  describe 'member routes' do
    describe 'posts' do
      [:notify_featured].each do |endpoint|
        it "routes #{endpoint} to the ArtistsController##{endpoint}" do
          expect({ post: "/artists/123/#{endpoint}" }).
            to route_to({controller: 'artists', id: '123', action: endpoint.to_s})
        end
      end
    end
  end

  describe "- route generation" do
    it "should map controller artists, id 10 and action show to /artists/10" do
      expect(get '/artists/10').to route_to(controller: "artists", id: "10", action: "show")
    end
    it "should map edit action properly" do
      expect(get '/artists/blrup/edit').to route_to(controller: "artists", action: "edit", id: 'blrup')
    end
    it "should map users/index to artists" do
      expect(get '/artists').to route_to(controller: "artists", action: "index")
    end
  end

  describe "- route recognition" do
    context "/artists/10" do
      it "map PUT to update" do
        expect(put "/artists/10").to route_to({controller: "artists", action: "update", id: "10" })
      end
      it "map GET to show" do
        expect(get "/artists/10").to route_to({controller: "artists", action: "show", id: "10" })
      end
      it "map POST to update" do
        expect(post "/artists/10").to route_to({controller: "artists", action: 'update' , id: '10'})
      end
      it "map DELETE /artists/10 as destroy" do

        expect(delete "/artists/10").to route_to({controller: "artists", action: "destroy", id: "10" })
      end
    end
  end

end
