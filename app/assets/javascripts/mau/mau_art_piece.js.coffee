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
    zoomBtn.colorbox()

  # validate upload data 
  validate: (frm) ->
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
  AP = new MAU.ArtPieces()
  AP.redirectOnHash()
  AP.setupZoomOnArtPiece()
