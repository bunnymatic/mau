# == Schema Information
#
# Table name: users
#
#  id                        :integer          not null, primary key
#  login                     :string(40)
#  name                      :string(100)      default("")
#  email                     :string(100)
#  crypted_password          :string(128)      default(""), not null
#  password_salt             :string(128)      default(""), not null
#  created_at                :datetime
#  updated_at                :datetime
#  remember_token            :string(40)
#  remember_token_expires_at :datetime
#  firstname                 :string(40)
#  lastname                  :string(40)
#  nomdeplume                :string(80)
#  url                       :string(200)
#  profile_image             :string(200)
#  studio_id                 :integer
#  activation_code           :string(40)
#  activated_at              :datetime
#  state                     :string(255)      default("passive")
#  deleted_at                :datetime
#  reset_code                :string(40)
#  email_attrs               :string(255)      default("{\"fromartist\": true, \"favorites\": true, \"fromall\": true}")
#  type                      :string(255)      default("Artist")
#  mailchimp_subscribed_at   :date
#  persistence_token         :string(255)
#  login_count               :integer          default(0), not null
#  last_request_at           :datetime
#  last_login_at             :datetime
#  current_login_at          :datetime
#  last_login_ip             :string(255)
#  current_login_ip          :string(255)
#  slug                      :string(255)
#  photo_file_name           :string(255)
#  photo_content_type        :string(255)
#  photo_file_size           :integer
#  photo_updated_at          :datetime
#
# Indexes
#
#  index_artists_on_login            (login) UNIQUE
#  index_users_on_last_request_at    (last_request_at)
#  index_users_on_persistence_token  (persistence_token)
#  index_users_on_slug               (slug) UNIQUE
#  index_users_on_state              (state)
#  index_users_on_studio_id          (studio_id)
#

class MauFan < User
end
