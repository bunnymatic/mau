class MauSerializer
  include JSONAPI::Serializer
  set_type name.underscore
end
