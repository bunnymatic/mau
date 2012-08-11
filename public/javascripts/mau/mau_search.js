(function() {
  var MAU, MAUSearch;

  MAU = window.MAU = window.MAU || {};

  MAU.SearchPage = MAUSearch = (function() {
    var sprite_minus_dom, sprite_plus_dom;

    sprite_minus_dom = '<div class="sprite minus" alt="hide" />';

    sprite_plus_dom = '<div class="sprite plus" alt="show" />';

    function MAUSearch(chooser_ids) {
      var _that;
      this.choosers = !_.isArray(chooser_ids) ? [chooser_ids] : chooser_ids;
      this.checkbox_selector = '.cb_entry input[type=checkbox]';
      _that = this;
      Event.observe(window, 'load', function() {
        _that.initExpandos();
        _that.initCBs();
        return _that.initAnyLinks();
      });
    }

    MAUSearch.prototype.initAnyLinks = function() {
      var _that;
      _that = this;
      return _.each(this.choosers, function(container) {
        var c, lnk;
        c = $(container);
        if (c) {
          lnk = c.select('a.reset').first();
        }
        if (lnk) {
          return Event.observe(lnk, 'click', function(ev) {
            var cbs;
            cbs = c.select(_that.checkbox_selector);
            _.each(cbs, function(el) {
              return el.checked = false;
            });
            _that.setAnyLink(c);
            ev.stop();
            return false;
          });
        }
      });
    };

    MAUSearch.prototype.setAnyLink = function(container) {
      var a, c, cbs, _that;
      _that = this;
      c = $(container);
      if (c) {
        cbs = c.select(this.checkbox_selector);
        a = c.select('a.reset');
        if (a && a.length) {
          if (_.uniq(_.map(cbs, function(c) {
            return c.checked;
          })).length > 1) {
            return a.first().show();
          } else {
            return a.first().hide();
          }
        }
      }
    };

    MAUSearch.prototype.initCBs = function() {
      var _that;
      _that = this;
      return _.each(this.choosers, function(c) {
        var $c, cbs;
        $c = $(c);
        if ($c) {
          cbs = $c.select(_that.checkbox_selector) || [];
          _.each(cbs, function(item, idx) {
            return Event.observe(item, 'change', function(ev) {
              return _that.setAnyLink(c);
            });
          });
          return _that.setAnyLink(c);
        }
      });
    };

    MAUSearch.prototype.initExpandos = function() {
      var expandeds, frm, searchForm, triggers, _that;
      _that = this;
      triggers = $$('.column .trigger');
      _.each(triggers, function(item) {
        item.insert({
          top: sprite_minus_dom
        });
        item.next().hide();
        return item.observe('click', _that.toggleTarget);
      });
      expandeds = $$('.column .expanded');
      _.each(expandeds, function(item) {
        item.insert({
          top: sprite_plus_dom
        });
        item.addClassName('trigger');
        return item.observe('click', _that.toggleTarget);
      });
      searchForm = $$('form.power_search');
      if (searchForm.length) {
        frm = searchForm[0];
        Event.observe(frm, 'submit', _that._submitForm);
        return false;
      }
    };

    MAUSearch.prototype._submitForm = function(ev) {
      var opts, searchForm;
      searchForm = $$('form.power_search');
      if (searchForm.length) {
        searchForm = searchForm[0];
        opts = {
          onSuccess: function(resp) {
            alert('success');
            $('search_results').innerHTML = resp.responseText;
            return false;
          },
          onFailure: function(resp) {
            alert('fail');
            return false;
          },
          onComplete: function(resp) {
            alert('complete');
            return false;
          }
        };
        ev.stop();
        searchForm.request(opts);
      }
      return false;
    };

    MAUSearch.prototype.toggleTarget = function(event) {
      var t, _that;
      _that = this;
      t = event.currentTarget || event.target;
      if (!t.hasClassName('expanded')) {
        t.addClassName('expanded');
        t.down('div').replace(sprite_plus_dom);
        t.next().blindDown(MAU.BLIND_OPTS.down);
      } else {
        t.removeClassName('expanded');
        t.down('div').replace(sprite_minus_dom);
        t.next().slideUp(MAU.BLIND_OPTS.up);
      }
      return false;
    };

    return MAUSearch;

  })();

  new MAUSearch(['medium_chooser', 'studio_chooser']);

}).call(this);
