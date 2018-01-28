# frozen_string_literal: true

class ProfileImage
  attr_reader :upload, :object

  def initialize(obj)
    @object = obj
  end
end
