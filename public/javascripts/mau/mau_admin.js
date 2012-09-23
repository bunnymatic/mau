
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
  M.Roles = {
    init: function() {
      /** bind events */
      var ctrls = $('role_mgr');
      if (ctrls) {
        var btn = ctrls.selectOne('.add_userrole');
        if (btn) {
          $(btn).observe('click', function() {
            var frm = ctrls.selectOne('form.edit_role')
            if (frm) {
              if (frm.visible()) {
                frm.hide();
              } else {
                frm.show();
              }
            }
          });
        }
      }
    }
  };

  M.init = function() {
    M.Roles.init();
    $$('.hide-rows input').each(function(el) {
      el.observe('change', function() {
        var clz = this.value;
        var show = this.checked;
        $$('table.admin-table tr.' + clz).each(function(row) {
          if (show) {
            row.fade();
          } else {
            row.appear();
          }
        });
      });
    });
    $$('button.update-artists').each(function(el) {
      el.observe('click', function() {
	var oss = $$('.fall2012');
	var cbs = $$('.cbfall2012');
	var ii = 0;
	var updates = {};
        if (oss && cbs) {
	  for ( ; ii < oss.length; ++ii ) {
	    os = oss[ii];
	    cb = cbs[ii];
	    
	    if ((os.innerHTML === 'true') !== (cbs[ii].checked)) {
	      updates["ARTIST"+os.readAttribute('artistid')] = (cbs[ii].checked).toString();
	    }
	  }
        }
	var form = new Element('form', {
          action: "/admin/artists/update",
          method: "post"
        });
	form.appendChild(new Element('input', { type:"hidden", 
                                                name:"authenticity_token", 
                                                value:unescape(authenticityToken)}));
        var k = null;
	for (k in updates) {
	  var val = updates[k];
	  form.appendChild(new Element('input', { type:"hidden", name:k, value:val }));
	}
	document.body.appendChild(form);
	form.submit();
	return false;
      });
    });

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

/* mau admin js */

(function() {

  var date_formatter = function(time_sec) {
    var t = time_sec * 1000;
    var dt = new Date(t);
    return dt.getMonth() + "/" + dt.getDate() + "/" + (''+dt.getFullYear()).substr(2);
  };

  var xticks = 5;
  var yticks = 4;
  var labelColor = "#c6c7d6";
  var lineColor = "#738294";
  var tickColor = '#222';
  var apd_options = {
    xaxis: { tickFormatter: date_formatter,
             noTicks: xticks, color: lineColor, max: new Date().valueOf()/1000 },
    yaxis: { noTicks: yticks, color: lineColor, min: 0},
    grid: { tickColor: tickColor },
    series: { color: labelColor }
  };

  var GraphPerDay = {
    load: function(selector, dataurl) {
      var ajax = new Ajax.Request(dataurl, {
        method: 'get',
        onSuccess: function(transport) {
          var json = transport.responseText.evalJSON();
          if (json.series && json.options) {
            json.options.bars = {show:true};
            Object.extend(json.series[0], apd_options.series);
            if (json.options.xaxis) {
              Object.extend(json.options.xaxis, apd_options.xaxis);
            } else {
              json.options.xaxis = apd_options.xaxis;
            }
            if (json.options.yaxis) {
              Object.extend(json.options.yaxis, apd_options.yaxis);
            } else {
              json.options.yaxis = apd_options.yaxis;
            }
            if (json.options.grid) {
              Object.extend(json.options.grid, apd_options.grid);
            } else {
              json.options.grid = apd_options.grid;
            }
            var $graph = $(selector);
            $graph.setStyle({display:'block'});
            f = Flotr.draw($graph, json.series, json.options);
          }
        }
      });
    }
  };
  if (/\/admin$/.test(location.href)) {
    Event.observe(window, 'load', function() { GraphPerDay.load('artists_per_day', '/admin/artists_per_day'); });
    Event.observe(window, 'load', function() { GraphPerDay.load('favorites_per_day', '/admin/favorites_per_day'); });
    Event.observe(window, 'load', function() { GraphPerDay.load('art_pieces_per_day', '/admin/art_pieces_per_day'); });
  }
  
})();
