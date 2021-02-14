class MauSerializer < JSONAPI::Serializable::Resource
  type { @object.class.name.underscore }
end
