var MAU = window.MAU = window.MAU || {};
(function() {
  var Favorites = {
    favorites_per_row : 20,
    bindings: function() {
      var favorites = $$('.favorite_this');
      $$('.favorite_this').each(function(lnk) {
        lnk.observe('click', function(ev) {
          var tp = lnk.readAttribute('fav_type');
          var id = lnk.readAttribute('fav_id');
          if (tp && id) {
            MAU.Utils.post_to_url('/users/add_favorite', {fav_type: tp,fav_id: id} );
          }
        });
      });

      // for favorite blocks (on artist show page)
      $$('.favorites-block').each( function(blk) {
        var _id = blk.readAttribute('id');
        var show_links = blk.select('.show-toggle');
        $(show_links).each(function(show_link) {
          show_link.addClassName('fewer');
          show_link.select('a').each( function(lnk) {
            lnk.writeAttribute('title','show all');
            lnk.observe('click', function(ev) {
              Favorites.show("#" + _id);
            });
          });
        });
      });

      var sm = $$('#my_favorites .show-toggle').first();
      if (sm) {
        sm.observe('click', function(ev) {
          Favorites.show('#my_favorites');
          ev.stopPropagation();
        });
      }
      sm = $$('#favorites_me .show-toggle').first();
      if (sm) {
        sm.observe('click', function(ev) {
          Favorites.show('#favorites_me');
          ev.stop();
        });
      }
    },
    execute_delete: function(ev) {
      var lnk = ev.target;
      var tp = lnk.readAttribute('fav_type');
      var id = lnk.readAttribute('fav_id');
      if (tp && id) {
        ev.stop();
        MAU.Utils.post_to_url('/users/remove_favorite', {fav_type: tp,fav_id: id} );
      }
    },
    show: function(block_id) {
      var thumbs = $$(block_id + ' .favorite-thumbs li');
      var show_link = $$(block_id + ' .show-toggle');
      var show_more = true;

      $(show_link).each(function(lk) {
        if (lk.hasClassName('fewer')) {
          Favorites.show_more(block_id);
          lk.removeClassName('fewer');
          lk.writeAttribute('title','show fewer');
          lk.innerHTML = 'hide';
        }
        else {
          Favorites.show_fewer(block_id);
          lk.addClassName('fewer');
          lk.writeAttribute('title','show more');
          lk.innerHTML = 'see all';
        }
      });
    },
    show_more: function(block_id) {
      console.log('show more');
      var thumbs = $$(block_id + ' .favorite-thumbs li');
      if (thumbs.length) {
        $(thumbs).each(function( item, itemidx ) {
          item.show();
        });
      }
    },
    show_fewer: function(block_id) {
      console.log('show fewer');
      var thumbs = $$(block_id + ' .favorite-thumbs li');
      if (thumbs.length) {
        $(thumbs).each(function( item, itemidx ) {
          if (itemidx < Favorites.favorites_per_row) {
            item.show();
          }
          else {
            item.hide();
          }
        });
      }
    },
  };

  MAU.Favorites = Favorites;

  jQuery(function() {
    $$('.favorites ul li .name .del-btn').each( function(el) {
      el.observe('click', Favorites.execute_delete);
    });

    /** setup bindings */
    MAU.Favorites.bindings();
  });

})();
