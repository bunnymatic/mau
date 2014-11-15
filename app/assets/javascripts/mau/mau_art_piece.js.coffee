MAU = window.MAU = window.MAU || {};

# do this outside of page load so it happens as soon as possible
if (location.hash && location.href.match(/art_pieces\/\d+/))
  newid = location.hash.substr(1);
  if (newid)
    urlbits = location.href.split('/')
    n = urlbits.length
    urlbits[n-1] = newid
    newurl = urlbits.join('/')
    location.href = newurl


MAU.ArtPieces = class ArtPieces

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
  jQuery("#artpiece_container a.zoom").colorbox()

  # bind click on image to 'check' the delete box for delete art page
  aps = jQuery('.thumbs-select .artp-thumb img')
  for ap in aps
    jQuery(ap).bind 'click', (ev) ->
     apid = jQuery(this).closest('li').find('input[type=checkbox]').click()

  # on art pieces edit page
  artPieceForm = jQuery('.edit_art_piece, .new_art_piece')
  if (artPieceForm.length)
    $('#art_piece_medium_id').select2();

    jQuery.ajax
      url: '/art_piece_tags/autosuggest'
      type: 'post'
      dataType: "json"
      success: (data) ->
        $("#tags").select2
          tags: data,
          tokenSeparators: [
            ","
          ]
          minimumInputLength: 3,
          multiple: true

  art_piece_form = document.getElementById('new_artpiece_form')
  if art_piece_form
    submit_button = jQuery(art_piece_form).find('input[type=submit]')
    if submit_button.length
      submit_button.bind 'submit', (ev) ->
        ArtPieces = new MAU.ArtPieces()
        if !ArtPieces.validate(art_piece_form)
          MAU.waitcursor()
          true
        else
          ev.preventDefault()
          false
