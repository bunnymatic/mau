module YouTubeHelper
  YOUTUBE_URL_REGEX = %r{\?(v=|embed/|v/?)([^&\s]+)?}
  YOUTUBE_SHORT_URL_REGEX = %r{//youtu\.be/(.*)$}

  def _embed_url_from_url(url)
    matches = YOUTUBE_URL_REGEX.match(url)
    video_id = (if matches
                  matches[2]
                else
                  matches = YOUTUBE_SHORT_URL_REGEX.match(url)
                  matches && matches[1]
                end)

    return nil unless video_id

    "https://www.youtube.com/embed/#{video_id}"
  end

  def embed_you_tube(url, title: '', height: 200, width: '100%')
    embed_url = _embed_url_from_url(url)

    return '' unless embed_url

    tag.iframe(
      width:,
      height:,
      src: embed_url,
      title:,
      frameborder: 0,
      allow: 'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture',
      allowfullscreen: true,
    ) {}
  end
end
