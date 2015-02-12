MAU = window.MAU = window.MAU || {}

Favorites =
  favorites_per_row : 20,
  bindings: ->
    jQuery('.pure-g').on 'click', '.favorite-this, .favorite_this', (ev) ->
      lnk = jQuery(this)
      tp = lnk.attr('fav-type');
      id = lnk.attr('fav-id');
      if (tp && id)
         MAU.Utils.post_to_url('/users/add_favorite', {fav_type: tp,fav_id: id} );

    # for favorite blocks (on artist show page)
    jQuery('.favorites-block').each () ->
      blk = jQuery(this)
      _id = blk.attr('id')
      blk.find('.show-toggle').each () ->
        show_link = jQuery(this)
        show_link.addClass('fewer')
        show_link.find('a').each () ->
          lnk = jQuery(this)
          lnk.attr('title','show all')
          lnk.bind 'click', (ev) ->
            Favorites.show("#" + _id);

    jQuery('#my_favorites .show-toggle').bind 'click', (ev) ->
      Favorites.show('#my_favorites')
      ev.preventDefault()
    jQuery('#favorites_me .show-toggle').bind 'click', (ev) ->
      Favorites.show('#favorites_me');
      ev.preventDefault()

  execute_delete: (ev) ->
    lnk = jQuery(ev.target)
    tp = lnk.attr('fav-type')
    id = lnk.attr('fav-id')
    if (tp && id)
      ev.preventDefault()
      MAU.Utils.post_to_url('/users/remove_favorite', {fav_type: tp,fav_id: id} )

  show: (block_id) ->
    thumbs = jQuery(block_id).find('.favorite-thumbs li')
    show_link = jQuery(block_id).find('.show-toggle');
    show_more = true
    show_link.each () ->
      lk = jQuery(@)
      if (lk.hasClass('fewer'))
        Favorites.show_more(block_id)
        lk.removeClass('fewer')
        lk.attr('title','show fewer')
        lk.html('hide')
      else
        Favorites.show_fewer(block_id)
        lk.addClass('fewer')
        lk.attr('title','show more')
        lk.html('show all')

  show_more: (block_id) ->
    thumbs = jQuery(block_id).find('.favorite-thumbs li').show();

  show_fewer: (block_id) ->
    thumbs = jQuery(block_id).find('.favorite-thumbs li')
    if (thumbs.length)
      thumbs.each ( itemidx, item ) ->
        if (itemidx < Favorites.favorites_per_row)
          jQuery(item).show()
        else
          jQuery(item).hide()

MAU.Favorites = Favorites;

jQuery ->
  jQuery('.favorites ul li .name .del-btn').bind 'click', Favorites.execute_delete
  MAU.Favorites.bindings();
