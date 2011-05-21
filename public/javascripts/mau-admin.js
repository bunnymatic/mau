/* mau admin js */

(function() {

  var date_formatter = function(time_sec) {
    var t = time_sec * 1000;
    var dt = new Date(t);
    return dt.getMonth() + "/" + dt.getDate() + "/" + dt.getFullYear();
  };

  var apd_options = {
    xaxis: { tickFormatter: date_formatter,
             noTicks: 10, color:'#738294' },
    yaxis: { noTicks: 10, color:'#738294' },
    grid: { verticalLines: false, horizontalLines: false },
    series: { color: '#c6c7d6' }
  };

  var ArtistsPerDay = {
    load: function() {
      new Ajax.Request('/admin/artists_per_day', {
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
            var $graph = $('artists_per_day');
            $graph.setStyle({display:'block'});
            f = Flotr.draw($graph, json.series, json.options);
          }
        }
      });
    }
  };
  
  Event.observe(window, 'load', ArtistsPerDay.load);

})();
