(function() {
  var MAU, MAUSearch, MAUSearchSpinner;

  MAU = window.MAU = window.MAU || {};

  MAU.SearchSpinner = MAUSearchSpinner = (function() {

    function MAUSearchSpinner() {
      this.spinnerBG = 'spinnerbg';
      this.spinnerFG = 'spinnerfg';
    }

    MAUSearchSpinner.prototype.create = function() {
      var bg, fg;
      if ($(this.spinnerBG)) {
        $(this.spinnerBG).remove();
      }
      bg = new Element('div', {
        id: this.spinnerBG,
        style: 'display:none;'
      });
      fg = new Element('div', {
        id: this.spinnerFG,
        'class': 'search_spinner'
      });
      bg.insert(fg);
      $$('#container')[0].insert(bg);
      return bg;
    };

    MAUSearchSpinner.prototype.show = function() {
      var spinner;
      spinner = $(this.spinnerBG);
      if (!spinner) {
        spinner = this.create();
      }
      spinner.clonePosition($('container'), {
        setLeft: false,
        setTop: false
      });
      return spinner.show();
    };

    MAUSearchSpinner.prototype.hide = function() {
      var spinner;
      spinner = $(this.spinnerBG);
      if (spinner) {
        return spinner.hide();
      }
    };

    return MAUSearchSpinner;

  })();

  MAU.SearchPage = MAUSearch = (function() {
    var sprite_minus_dom, sprite_plus_dom;

    sprite_minus_dom = '<div class="sprite minus" alt="hide" />';

    sprite_plus_dom = '<div class="sprite plus" alt="show" />';

    function MAUSearch(chooserIds, currentSearch) {
      var _that;
      this.currentSearch = currentSearch;
      this.choosers = !_.isArray(chooserIds) ? [chooserIds] : chooserIds;
      this.checkboxSelector = '.cb_entry input[type=checkbox]';
      this.searchFormSelector = 'form.power_search';
      this.spinner = new MAUSearchSpinner();
      _that = this;
      Event.observe(window, 'load', function() {
        _that.initExpandos();
        _that.initCBs();
        _that.initAnyLinks();
        return _that.initFormSubmitOnChange();
      });
    }

    MAUSearch.prototype.initAnyLinks = function() {
      var _that;
      _that = this;
      return _.each(this.choosers, function(container) {
        var c, lnk;
        c = $(container);
        if (c) {
          lnk = c.selectOne('.reset a');
        }
        _that.setAnyLink(c);
        if (lnk) {
          return Event.observe(lnk, 'click', function(ev) {
            var cbs;
            cbs = c.select(_that.checkboxSelector);
            _.each(cbs, function(el) {
              return el.checked = false;
            });
            _that.setAnyLink(c);
            ev.stop();
            _that._submitForm();
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
        cbs = c.select(this.checkboxSelector + ":checked");
        a = c.selectOne('.reset a');
        if (a) {
          if (cbs.length) {
            return a.show();
          } else {
            return a.hide();
          }
        }
      }
    };

    MAUSearch.prototype.initFormSubmitOnChange = function() {
      var os_chooser, _that;
      _that = this;
      os_chooser = $('os_artist');
      if (os_chooser) {
        os_chooser.observe('change', function(ev) {
          return _that._submitForm(ev);
        });
      }
      return _.each(this.choosers, function(c) {
        var $c, debounced, s;
        $c = $(c);
        if ($c) {
          s = function() {
            return _that._submitForm();
          };
          debounced = s.debounce(500, false);
          return _.each($c.select(_that.checkboxSelector), function(item) {
            return Event.observe(item, 'change', debounced);
          });
        }
      });
    };

    MAUSearch.prototype.initCBs = function() {
      var _that;
      _that = this;
      return _.each(this.choosers, function(c) {
        var $c;
        $c = $(c);
        if ($c) {
          _.each($c.select(_that.checkboxSelector), function(item, idx) {
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
      searchForm = $$(this.searchFormSelector);
      if (searchForm.length) {
        frm = searchForm[0];
        Event.observe(frm, 'submit', function(ev) {
          return _that._submitForm(ev);
        });
        return false;
      }
    };

    MAUSearch.prototype.updateQueryParamsInView = function() {
      var ctx, frm, kw, kw_block, med_block, ms, os, os_info, oss, ss, studio_block, _that;
      _that = this;
      frm = $$(_that.searchFormSelector);
      if (frm.length) {
        frm = frm[0];
        ms = _.map(frm.select('#medium_chooser input:checked'), function(item) {
          return item.data('display');
        });
        ss = _.map(frm.select('#studio_chooser input:checked'), function(item) {
          return item.data('display');
        });
        os = null;
        try {
          os = frm.select('#os_artist')[0].selected().value;
        } catch (err) {
          os = null;
        }
        kw = _.map(frm.select('#keywords')[0].getValue().split(","), function(s) {
          return s.trim();
        });
        ctx = $$('.current_search');
        if (ctx.length) {
          ctx = ctx[0];
          kw_block = ctx.select('.block.keywords ul.keywords')[0];
          if (kw_block) {
            kw_block.html('');
            _.each(kw, function(k, idx) {
              var li, s;
              s = k;
              if (!!idx) {
                s = "AND " + s;
              }
              li = new Element('li').update(s);
              return kw_block.insert(li);
            });
          }
          med_block = ctx.select('.block.mediums ul')[0];
          if (med_block) {
            med_block.html('');
            if (ms.length) {
              _.each(ms, function(m) {
                return med_block.insert(new Element('li').update(m));
              });
            } else {
              med_block.insert(new Element('li').update('Any'));
            }
          }
          studio_block = ctx.select('.block.studios ul')[0];
          if (studio_block) {
            studio_block.html('');
            if (ss.length) {
              _.each(ss, function(s) {
                return studio_block.insert(new Element('li').update(s));
              });
            } else {
              studio_block.insert(new Element('li').update('Any'));
            }
          }
          os_info = ctx.select('.block.os .os')[0];
          if (os_info) {
            oss = "Don't Care";
            if (os) {
              oss = {
                '1': 'Yes',
                '2': 'No'
              }[os];
            }
            return os_info.html(oss);
          }
        }
      }
    };

    MAUSearch.prototype._submitForm = function(ev) {
      var frm, opts, _that;
      _that = this;
      frm = $$(_that.searchFormSelector);
      this.spinner.show();
      if (frm.length) {
        frm = frm[0];
        opts = {
          onSuccess: function(resp) {
            $('search_results').innerHTML = resp.responseText;
            return false;
          },
          onFailure: function(resp) {
            return false;
          },
          onComplete: function(resp) {
            _that.updateQueryParamsInView();
            _that.spinner.hide();
            return false;
          }
        };
        if (ev) {
          ev.stop();
        }
        frm.request(opts);
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
