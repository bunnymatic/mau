After do |_scenario|
  FileUtils.rm_rf(Dir["#{Rails.root}/tmp/paperclip_test/"])
end
