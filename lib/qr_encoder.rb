module QrEncoder
  def qrencode path, url, size=10
    cmd = "qrencode -s #{size} -o #{path} \"#{url}\""
    RAILS_DEFAULT_LOGGER.info("CMD: #{cmd}")
    system "qrencode -s #{size} -o #{path} \"#{url}\""
    return path
  end
end
