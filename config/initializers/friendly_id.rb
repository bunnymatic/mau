FriendlyId.defaults do |config|
  config.use :reserved
  # Reserve words for English and Spanish URLs
  config.reserved_words = %w(new edit show manage_art delete_art destroyart setarrangement arrange_art map_page suggest)
end
