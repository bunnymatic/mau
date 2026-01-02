# Be sure to restart your server when you modify this file.

# as of Rails 3, `include_root_in_json` default was false.
# we built this app assuming it's true so make it so
if defined?(ActiveRecord)
  # Include Active Record class name as root for JSON serialized output.
  ActiveRecord::Base.include_root_in_json = true
end
