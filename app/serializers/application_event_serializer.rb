class ApplicationEventSerializer < MauSerializer

  attributes :user, :message, :type

  def user
    object.data.fetch("user", nil)
  end

end
