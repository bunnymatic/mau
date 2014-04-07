
MAUAdmin =  window.MAUAdmin || {};

(function() {
  Element.prototype.triggerEvent = function(eventName)
  {
    if (document.createEvent)
    {
      var evt = document.createEvent('HTMLEvents');
      evt.initEvent(eventName, true, true);

      return this.dispatchEvent(evt);
    }

    if (this.fireEvent) {
      return this.fireEvent('on' + eventName);
    }
  };

  var M = MAUAdmin;

  jQuery(function() {
    jQuery('.js-hideable-rows').hideableRows()
  });

  M.init = function() {

    var oscombo = $('os_combo_link');
    if (oscombo) {
        oscombo.observe('click', function() {
          var $frm = $('multi_form');
          if (!$frm.visible()) {
            $frm.slideDown();
          } else {
            $frm.slideUp();
          }
        });
    }

  };
  Event.observe(window,'load',M.init);

  var E = M.Events = M.Events || {};
  E.init = function() {
    $$('.filters input[type=checkbox]').each(function(lnk) {
      lnk.observe('change',function() {
        var time_filters = [];
        var state_filters = [];
        $$('.filters input.time[type=checkbox]').each(function(checked) {
          if (checked.checked) {
            time_filters.push(checked.getValue());
          }
        });
        $$('.filters input.state[type=checkbox]').each(function(checked) {
          if (checked.checked) {
            state_filters.push(checked.getValue());
          }
        });
        $$('.event').each(function(el){el.hide();});
        state_filters.each(function(state_class) {
          time_filters.each(function(time_class) {
            $$( ['.event',time_class, state_class].join('.') ).each(function(el){el.show();});
          });
        });

      });
    });
    $$('.filters .show_all').each(function(el) {
      el.observe('click', function() {
        $$('.filters input[type=checkbox]').each(function(ck) {
          ck.checked = true;
          $$('.event').each(function(el){el.show();});
        });
      });
    });
    // start with only future, inprogress and unpublished
    var k = null;
    var init_state = { future: true,
                       in_progress: true,
                       past: false,
                       published: false,
                       unpublished: true};
    for (k in init_state) {
      var $ev_filter = $('event_filter_'+k);
      if ($ev_filter) {
        $ev_filter.checked = init_state[k];
        $ev_filter.triggerEvent('change');
      }
    }
  };
  Event.observe(window,'load',E.init);


  /** internal email lists */
  var EL = M.InternalEmailLists = MAUAdmin.InternalEmailLists || {};
  EL.init = function() {
    $$('.del_btn').each(function(btn) {
      $(btn).observe('click', function(ev) {
        var li = $(btn).firstParentByTagName('li');
        var ul = $(btn).firstParentByTagName('ul');
        if (li && ul) {
          var email = li.firstChild.nodeValue.strip();
          var email_id = li.getAttribute('email_id');
          var listname = ul.getAttribute('list_type');
          if ( email && listname && email_id ) {
            if (confirm('Whoa Nelly!  Are you sure you want to remove ' + email + ' from the ' + listname + ' list?')) {
              var data_url = '/email_list/';
              var ajax = new Ajax.Request(data_url, {
                method: 'post',
                parameters: {
                  authenticity_token:unescape(authenticityToken),
                  'email[id]': email_id,
                  listtype: listname,
                  method: 'remove_email'
                },
                onSuccess: function(transport) {
                  li.remove();
                }
              });
            }
          }
        }
        ev.stop();
        return false;
      });
    });
    $$('.add_btn').each(function(btn) {
      $(btn).observe('click', function(ev) {
        var li = $(btn).firstParentByTagName('li');
        if (li) {
          var container = $(li).select('.add_email');
          if (container) {
            var c = $(container[0]);
            if ($(c).visible()) {
              $(c).slideUp();
            } else {
              $(c).slideDown();
            }
          }
        }
        ev.stop();
        return false;
      });
    });
  };
  Event.observe(window, 'load', EL.init);

})();
