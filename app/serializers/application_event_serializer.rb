class ApplicationEventSerializer < MauSerializer
  attributes :user, :message, :type, :created_at

  attribute :user do
    @object.data.fetch('user', nil)
  end
end
