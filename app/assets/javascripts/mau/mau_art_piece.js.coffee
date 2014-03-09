MAU = window.MAU = window.MAU || {};
MAU.ArtPieces = class ArtPieces

  redirectOnHash: ->
    if (location.hash && location.href.match(/art_pieces\/\d+/))
      newid = location.hash.substr(1);
      if (newid)
        urlbits = location.href.split('/')
        n = urlbits.length
        urlbits[n-1] = newid
        newurl = urlbits.join('/')
        location.href = newurl

    aps = jQuery('.thumbs-select .artp-thumb img')
    for ap in aps
      jQuery(ap).bind 'click', (ev) ->
	      apid = jQuery(this).parent().readAttribute('pid');
	      inp = jQuery('#art_'+apid);
	      if (inp)
	        inp.click()

  setupZoomOnArtPiece: ->
    zoomBtn = jQuery('#artpiece_container a.zoom')
    _.each zoomBtn, (zoom) ->
      jQuery(zoom).bind 'click', (ev) ->
        ev.stopPropagation();
        t = ev.currentTarget || ev.target;
        # current target/target work around for IE
        if (t.tagName == 'DIV' && /micro/.test(t.className)) # hit the zoom div 
          t = jQuery(t).parent()
        t = jQuery(t)
        # we're not using data below because it appears to be cached in some strange way
        # - probably related to our redefinition of the data element for prototype
        opts = {
          image: {
            url: t.attr('data-image'),
            width: t.attr('data-imagewidth'),
            height: t.attr('data-imageheight')
          }
        }
                                     
        MAU.ImageLightbox.init opts
        MAU.ImageLightbox.show({position:'center'});

  # validate upload data 
  validate_art_piece: (frm) ->
    input_filename = jQuery(frm).find('#upload_datafile')
    if (input_filename.length)
      fname = input_filename.val()
      re = /[\#|\*|\(|\)|\[|\]|\{|\}|<|\>|\$|\!\?|\;|\'\"]/;
      if (fname.match(re))
        s = """
            You need to change the filename of the file you're
            trying to upload.  We don't do well with quotation
            marks and other special characters
            ( like | or [] or {} or * or # or ; ).
            Please rename that file before trying to upload again.
            """
        alert s
          

jQuery ->
  AP = new  MAU.ArtPieces()
  AP.redirectOnHash()
  AP.setupZoomOnArtPiece()
