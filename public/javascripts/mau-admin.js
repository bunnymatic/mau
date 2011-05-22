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
             noTicks: xticks, color: lineColor },
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
