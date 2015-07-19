class StudioSerializer < MauSerializer
  attributes :id, :name, :street_address, :city, :map_url, :url

  def url
    studio_url(object)
  end
  
  def street_address
    address = object.address_hash.parsed.street
  end

  def city
    address = object.address_hash.parsed.city
  end

  def map_url
    object.map_link
  end

end
