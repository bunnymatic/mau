# == Schema Information
#
# Table name: users
#
#  id                        :integer          not null, primary key
#  login                     :string(40)
#  name                      :string(100)      default("")
#  email                     :string(100)
#  crypted_password          :string(40)
#  salt                      :string(40)
#  created_at                :datetime
#  updated_at                :datetime
#  remember_token            :string(40)
#  remember_token_expires_at :datetime
#  firstname                 :string(40)
#  lastname                  :string(40)
#  nomdeplume                :string(80)
#  phone                     :string(16)
#  url                       :string(200)
#  profile_image             :string(200)
#  studio_id                 :integer
#  facebook                  :string(200)
#  twitter                   :string(200)
#  blog                      :string(200)
#  myspace                   :string(200)
#  flickr                    :string(200)
#  activation_code           :string(40)
#  activated_at              :datetime
#  state                     :string(255)      default("passive")
#  deleted_at                :datetime
#  reset_code                :string(40)
#  image_height              :integer          default(0)
#  image_width               :integer          default(0)
#  max_pieces                :integer          default(20)
#  email_attrs               :string(255)      default("{\"fromartist\": true, \"favorites\": true, \"fromall\": true}")
#  studionumber              :string(255)
#  type                      :string(255)      default("Artist")
#  mailchimp_subscribed_at   :date
#
# Indexes
#
#  index_artists_on_login  (login) UNIQUE
#

class MAUFan < User
end
