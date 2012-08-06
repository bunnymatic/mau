(function() {
  var MAU, MAUSearch, s;

  MAU = window.MAU = window.MAU || {};

  MAU.SearchPage = MAUSearch = (function() {
    var sprite_minus_dom, sprite_plus_dom;

    sprite_minus_dom = '<div class="sprite minus" alt="hide" />';

    sprite_plus_dom = '<div class="sprite plus" alt="show" />';

    function MAUSearch() {}

    MAUSearch.prototype.init = function() {
      var expandeds, frm, searchForm, triggers;
      triggers = $$('.column .trigger');
      _.each(triggers, function(item) {
        item.insert({
          top: sprite_minus_dom
        });
        item.next().hide();
        return item.observe('click', MAUSearch.toggleTarget);
      });
      expandeds = $$('.column .expanded');
      _.each(expandeds, function(item) {
        item.insert({
          top: sprite_plus_dom
        });
        item.addClassName('trigger');
        return item.observe('click', MAUSearch.toggleTarget);
      });
      searchForm = $$('form.power_search');
      if (searchForm.length) {
        frm = searchForm[0];
        return Event.observe(frm, 'submit', function(ev) {
          var opts;
          opts = {
            onSuccess: function(resp) {
              $('search_results').innerHTML = resp.responseText;
              return false;
            }
          };
          ev.stop();
          frm.request(opts);
          return false;
        });
      }
    };

    MAUSearch.toggleTarget = function(event) {
      var t, _that;
      _that = this;
      t = event.currentTarget || event.target;
      if (!t.hasClassName('expanded')) {
        t.addClassName('expanded');
        t.down('div').replace(sprite_plus_dom);
        return t.next().blindDown(MAU.BLIND_OPTS.down);
      } else {
        t.removeClassName('expanded');
        t.down('div').replace(sprite_minus_dom);
        return t.next().slideUp(MAU.BLIND_OPTS.up);
      }
    };

    return MAUSearch;

  })();

  s = new MAUSearch();

  Event.observe(window, 'load', s.init);

}).call(this);
