module QrEncoder
  def qrencode path, url, size=10
    cmd = "qrencode -s #{size} -o #{path} \"#{url}\""
    RAILS_DEFAULT_LOGGER.info("CMD: #{cmd}")
    result = system cmd
    if not result
      RAILS_DEFAULT_LOGGER.error("Failed to generate qr code #{$?}")
    end
    return path
  end
end
