/* mau admin js */

jQuery(function() {

  if (jQuery('body.admin .graph').length) {
    // graphs are on this page
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
        jQuery.ajax({
          url:dataurl,
          method: 'get',
          success: function(data, status, xhr) {
            if (data.series && data.options) {
              default_opts = {bars: {show:true} }
              data.options = jQuery.extend(default_opts, apd_options);
              jQuery.plot( jQuery(selector), data.series, data.options);
            }
          }
        });
      }
    };

    GraphPerDay.load('#artists_per_day', '/admin/artists_per_day');
    GraphPerDay.load('#favorites_per_day', '/admin/favorites_per_day');
    GraphPerDay.load('#art_pieces_per_day', '/admin/art_pieces_per_day');
    GraphPerDay.load('#os_signups', '/admin/os_signups');

  } // end if we're on the admin page with graphs
});
