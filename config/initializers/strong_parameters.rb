# frozen_string_literal: true
ActiveRecord::Base.class_eval do
  include ActiveModel::ForbiddenAttributesProtection
end
