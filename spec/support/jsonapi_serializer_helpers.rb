module JsonapiSerializerHelpers
  def serialize(obj, serializer)
    r = JSONAPI::Serializable::Renderer.new
    r.render(obj, class: { obj.class.name.to_sym => serializer })
  end
end

RSpec.configure do |config|
  config.include JsonapiSerializerHelpers
end
