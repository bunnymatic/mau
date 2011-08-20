
MAUAdmin =  window['MAUAdmin'] || {};

(function() {
  var M = MAUAdmin;
  M.init = function() {
    $$('button.update-artists').each(function(el) {
      el.observe('click', function() {
	var oss = $$('.os2010');
	var cbs = $$('.cb2010');
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
	var oss = $$('.oct2011');
	var cbs = $$('.cboct2011');
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
	form.appendChild(new Element('input', { type:"hidden", name:"authenticity_token", value:unescape(authenticityToken)}));
	for (k in updates) {
	  var val = updates[k];
	  form.appendChild(new Element('input', { type:"hidden", name:k, value:val }));
	}
	document.body.appendChild(form);
	form.submit();
	return false;
      });
    });
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
            MAU.log( 'Show ' + ['event',time_class, state_class].join('.') );
            $$( ['.event',time_class, state_class].join('.') ).each(function(el){el.show();});
          })
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
  };
  Event.observe(window,'load',E.init);

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
      new Ajax.Request(dataurl, {
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
  
  Event.observe(window, 'load', function() { GraphPerDay.load('artists_per_day', '/admin/artists_per_day'); });
  Event.observe(window, 'load', function() { GraphPerDay.load('favorites_per_day', '/admin/favorites_per_day'); });
  Event.observe(window, 'load', function() { GraphPerDay.load('art_pieces_per_day', '/admin/art_pieces_per_day'); });


})();
