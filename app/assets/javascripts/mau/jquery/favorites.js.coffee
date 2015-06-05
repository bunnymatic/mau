MAU = window.MAU = window.MAU || {}

Favorites =
  execute_delete: (ev) ->
    ev.preventDefault()
    if confirm('Are you sure you want to remove this as a favorite?') 
      lnk = jQuery(this)
      tp = lnk.attr('fav-type')
      id = lnk.attr('fav-id')
      if (tp && id)
        MAU.Utils.post_to_url('/users/remove_favorite', {fav_type: tp,fav_id: id} )

MAU.Favorites = Favorites;

jQuery ->
  jQuery('.js-remove-favorite').bind 'click', Favorites.execute_delete
  jQuery('.pure-g').on 'click', '.favorite-this, .favorite_this', (ev) ->
    lnk = jQuery(this)
    tp = lnk.attr('fav-type');
    id = lnk.attr('fav-id');
    if (tp && id)
       MAU.Utils.post_to_url('/users/add_favorite', {fav_type: tp,fav_id: id} );
