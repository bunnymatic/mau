# frozen_string_literal: true

class ArtistInfoSerializer < MauSerializer
  attributes :bio, :street, :city, :addr_state, :zipcode, :studionumber, :lat, :lng
end
