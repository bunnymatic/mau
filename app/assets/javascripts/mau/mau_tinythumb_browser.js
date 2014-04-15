(function() {

  var MAU = window.MAU = window.MAU || {};
  var Thumb = MAU.Thumbs = MAU.Thumbs || {};

  Thumb.APCache = {};
  Thumb.Helpers = {
    find_thumb: function(apid) {
      var i = 0;
      if (Thumb.ThumbList) {
        var n = Thumb.ThumbList.length;
        for(;i<n;++i) {
          var t = Thumb.ThumbList[i];
          if (t.id == apid) {
            return i;
          }
        }
        return null;
      }
    },
    safe_update: function(id, val) {
      var el = jQuery('#'+id);
      if (el) {
        el.html(val ? val : '')
        if(val) {
          el.show();
        } else {
          el.hide();
        }
      }
    },
    updatePinItButton: function(pinIt, artPiece) {
      if (pinIt) {
        var pic = location.protocol + "//" + location.host + artPiece.image_files.large;
        var url = location.protocol + "//" + location.host + '/art_pieces/' + artPiece.id;
        var desc = artPiece.title + " by " + artPiece.artist_name;
        var parser = new MAU.QueryStringParser("//pinterest.com/pin/create/button/");
        parser.query_params = { url: url,
                                description: desc,
                                media: pic };
        var newHref =  parser.toString(true);
        jQuery(pinIt).attr('href', newHref);
      }
    },
    update_highlight: function() {
      var idx = Thumb.curIdx;
      var ts = jQuery('div.tiny-thumb');
      ts.removeClass('tiny-thumb-sel');
      jQuery(ts[idx]).addClass('tiny-thumb-sel');
    },
    update_tags: function(tags) {
      // if there ap.tags then run format tags
      tags = tags || []
      var formattedTags = (new MAU.TagMediaHelper(tags, 'tag', true, {'class' : 'tag'})).format()
      var tgs = jQuery('#ap_tags');

      // if we found the tags element on the page
      if (tgs) {
        var i = 0;
        var ntags = formattedTags.length;
        if (ntags) {
          tgs.html( formattedTags );
          tgs.show();
        } else {
          tgs.hide();
        }
      }
    },
    update_info: function(ap) {
      var dummy = null;
      var images = ap.image_files;
      var f = images.medium;
      var img = $('artpiece_img');
      if (f) {
        img.src = f;
        this.safe_update('artpiece_title',ap.title);
        this.safe_update('ap_title', ap.title);
        this.safe_update('ap_dimensions', decodeURI(ap.dimensions));
        this.safe_update('ap_year',ap.year);
        this.safe_update('ap_favorites',ap.favorites_count);
        this.safe_update('num_favorites',ap.favorites_count);
        var med = (new MAU.TagMediaHelper(ap.medium, 'medium', true)).format()
        this.safe_update('ap_medium', med.first());

        this.update_tags(ap.tags);

        if (img) {
          img.show();
        }
        var inf = $('artpiece_container').selectOne('.art-piece-info');
        if (inf) {
          inf.setStyle({width: ap.image_dimensions.medium[0] + 'px'});
        }
        // hides errors/notices
        $$('.notice').each(function(el) {
          if (el.visible()) {
            el.fadeOut({duration:0.3,
                     afterFinish: function() {el.remove();}});
          }
        });
        $$('.error-msg').each(function(el) {
          if (el.visible()) {
            el.fade({duration:0.3,
                     afterFinish: function() {el.remove();}});
          }
        });

        var $zoom = $$('a.zoom')[0];
        if ($zoom) {
          var _that = this;
          $zoom.href = images.large;
          $zoom.title = ap.title
        }
        var $favs = $$('.favorite_this');
        if ($favs.length > 0) {
          $favs[0].setAttribute('fav_id', ap.id);
        }
        var $shares = $$('.action-icons a');
        if ($shares.length > 0) {
          $shares.each(function(lnk) {
            var href = lnk.getAttribute('href');
            href = href.replace(/(%2Fart_pieces%2F)\d+(.*)/,"$1"+ap.id+"$2" );
            lnk.writeAttribute('href', href);
          });
        }
        var $edits = $$('.edit-buttons a');
        if ($edits.length > 0) {
          $edits.each(function(lnk) {
            var href = lnk.getAttribute('href');
            href = href.replace(/(art_pieces\/)\d+(.*)/,"$1"+ap.id+"$2" );
            lnk.writeAttribute('href', href);
          });
        }

        try{
          /* update facebook button*/
          var fb = $('artpiece_container').selectOne('.fb-like');
          if (fb) {
            var href = (fb.getAttribute('data-href') || location.href).replace(/\#.*$/,'');
            href = href.replace(/(art_pieces\/)\d+(.*)/,"$1"+ap.id+"$2" );
            fb.writeAttribute("data-href", href);
          }
          FB.XFBML.parse();
        } catch(ex) {}

        /* update pinterest */
        var pint = $('artpiece_container').selectOne('span.pinterest a');
        this.updatePinItButton(pint, ap);
      }
    },
    update_page: function() {
      var idx = Thumb.curIdx;
      var ap = Thumb.ThumbList[idx];
      var url = "/art_pieces/" + ap.id + ".json";

      Thumb.Helpers.update_highlight();
      location.hash = "#" + ap.id;
      var img = $('artpiece_img');
      if (Thumb.APCache[ap.id]) {
        var a = Thumb.APCache[ap.id];
        Thumb.Helpers.update_info(a);
      } else {
        jQuery.ajax({
          url: url,
          dataType: 'json',
          success: function(data,status,xhr) {
            if ('attributes' in data) {
              ap = data.attributes;
            }
            else {
              ap = data.art_piece;
            }
            Thumb.APCache[ap.id] = ap;
            Thumb.Helpers.update_info(ap);
            ap.cache=true;
          },
          error: function(e) {
            MAU.log('Failed to update page');
            MAU.log(e);
          }
        });
      }
      return true;
    }
  };

  Thumb.jumpToIdx = function (idx) {
    if (Thumb.ThumbList) {
      var n = Thumb.ThumbList.length;
      if (idx < 0) { idx = n-1; }
      idx = idx % n;
      var ap = Thumb.ThumbList[idx];
      Thumb.curIdx = idx;
      Thumb.Helpers.update_page();
    }
    return false;
  };

  Thumb.jumpTo = function(ap_id) {
    var idx = Thumb.Helpers.find_thumb(ap_id);
    Thumb.jumpToIdx(idx);
  };
  Thumb.jumpNext = function(ev) {
    ev.stopPropagation();
    Thumb.jumpToIdx(Thumb.curIdx+1);
  };
  Thumb.jumpPrevious = function(ev) {
    ev.stopPropagation();
    Thumb.jumpToIdx(Thumb.curIdx-1);
  };


  function keypressHandler (event)
  {
    event.stopPropagation();
    // I think this next line of code is accurate,
    // but I don't have a good selection of browsers
    // with me today to test this effectivly.
    var key = event.which || event.keyCode;
    switch (key) {
    case Event.KEY_RIGHT:
      Thumb.jumpNext(event);
      break;
    case Event.KEY_LEFT:
      Thumb.jumpPrevious(event);
      break;
    default:
      break;
    }
  }

  Thumb.curIdx = 0;

  Thumb.init = function() {
    // only run this if we are on the right page
    if (jQuery('#container.art_pieces').length) {
      jQuery(document).bind('keydown', keypressHandler );
      jQuery('#prev_img_lnk').bind('click', function(ev) { Thumb.jumpPrevious(ev); });
      jQuery('#next_img_lnk').bind('click', function(ev) { Thumb.jumpNext(ev); });

      jQuery('a.jump-to').bind('click', function(ev) {
        jumpLink = this
        ev.preventDefault();
        location.href = jumpLink.href;
        var apid = location.hash.substr(1);
        if (apid) {
          Thumb.jumpTo(apid);
          return false;
        }
      });

      Thumb.init = function(){};
    }
  };

  jQuery(Thumb.init)
})();
