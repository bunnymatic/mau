/*global  */
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
    var apd_options = {
      xaxis: { tickFormatter: date_formatter,
               noTicks: xticks, max: new Date().valueOf()/1000 },
      yaxis: { noTicks: yticks, min: 0}
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

    GraphPerDay.load('#artists_per_day', '/admin/stats/artists_per_day'); 
    GraphPerDay.load('#user_visits_per_day', '/admin/stats/user_visits_per_day');
    GraphPerDay.load('#favorites_per_day', '/admin/stats/favorites_per_day');
    GraphPerDay.load('#art_pieces_per_day', '/admin/stats/art_pieces_per_day');
    GraphPerDay.load('#os_signups', '/admin/stats/os_signups');

  } // end if we're on the admin page with graphs
});
