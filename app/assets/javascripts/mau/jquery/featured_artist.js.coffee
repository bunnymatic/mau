jQuery ->
  initFeaturedArtist = ->
    imFeatured = jQuery('.featured .artist_info .controls .formbutton')
    if (imFeatured.length)
      artist = imFeatured.data('artist')
      imFeatured.bind 'click', ->
        xhr = jQuery.ajax
          url: '/admin/artists/' + artist + '/notify_featured'
          method: 'post'
          data: { authenticity_token:unescape(authenticityToken) }
          success: (data, status, xhr) ->
            (new MAU.Flash()).show({notice:'Awesome.  We\'ve sent this artist a note telling them they\'ve been featured.'}, '.singlecolumn .featured')
          failure: () ->
            (new MAU.Flash()).show({error:'failed to notify the artist.  please contact your system administrator'}, '.singlecolumn .featured')
  initFeaturedArtist()
