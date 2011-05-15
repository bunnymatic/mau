class AddMailchimpSubscribedAtToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :mailchimp_subscribed_at, :date
  end

  def self.down
    remove_column :users, :mailchimp_subscribed_at
  end
end
