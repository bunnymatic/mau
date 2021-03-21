module YouTubeHelper
  YOUTUBE_URL_REGEX = %r{\?(v=|embed/|v/?)(\S+)?$}.freeze

  def embed_you_tube(url, title: '', height: 200, width: '100%')
    matches = YOUTUBE_URL_REGEX.match(url)
    return '' unless matches

    embed_url = "https://www.youtube.com/embed/#{matches[2]}"
    tag.iframe({ width: width,
                 height: height,
                 src: embed_url,
                 title: title,
                 frameborder: 0,
                 allow: 'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture',
                 allowfullscreen: true }) {}
  end
end
