# frozen_string_literal: true
class EmailSerializer < ::ActiveModel::Serializer
  attributes :id, :email, :name
end
