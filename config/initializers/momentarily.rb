require 'momentarily'

if Rails.env != 'test'
  Momentarily.debug = true #(Rails.env != 'production')
  Momentarily.start
end
