require 'active_storage/service/disk_service'
class ActiveStorage::Service::DiskWithHostService < ActiveStorage::Service::DiskService # rubocop:disable Style/ClassAndModuleChildren
  def url_options
    Rails.application.default_url_options
  end
end
