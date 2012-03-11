module QrEncoder
  def qrencode path, url, size=10
    system "qrencode -s #{size} -o #{path} \"#{url}\" "
    return path
  end
end
