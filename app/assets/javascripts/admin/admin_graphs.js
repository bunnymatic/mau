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
      xaxis: {
        tickFormatter: date_formatter,
        noTicks: xticks, max: new Date().valueOf()/1000 },
      yaxis: {
        noTicks: yticks,
        min: 0
      }
    };

    var GraphPerDay = {
      load: function(selector, dataurl) {
        jQuery.ajax({
          url:dataurl,
          method: 'get',
          success: function(data, status, xhr) {
            if (data.series && data.options) {
              var default_opts = {bars: {show:true} }
              data.options = jQuery.extend(default_opts, apd_options);
              jQuery.plot( jQuery(selector), data.series, data.options);
            }
          }
        });
      }
    };

    var PlainGraph = {
      load: function(selector, dataurl) {
        jQuery.ajax({
          url:dataurl,
          method: 'get',
          success: function(data, status, xhr) {
            if (data.series && data.options) {
              data.options = {bars: {show:true} }
              jQuery.plot( jQuery(selector), data.series, data.options);
            }
          }
        });
      }
    };

    var C3Graph = {
      load: function(selector, dataurl) {
        jQuery.ajax({
          url: dataurl,
          method: 'get',
          success: function( data, status, xhr) {
            if (data.series && data.options) {
              console.log( data.series)
              console.log( selector)
              debugger
              var chart = c3.generate({
                bindto: selector,
                data: {
                  columns: [
                    ['# pieces'].concat(data.series[0].data.map(function(entry) { return entry[1]; }))
                  ],
                  type: 'bar'
                },
                axis: {
                  y: {
                    max: 20,
                    label: {
                      text: '# pieces'
                    }
                  },
                  x: {
                  }
                },
                bar: {
                  width: {
                    ratio: 0.5 // this makes bar width 50% of length between ticks
                  }
                  // or
                  //width: 100 // this makes bar width 100px
                }
              });

            }
          }
        });
      }
    }

    GraphPerDay.load('#artists_per_day', '/admin/stats/artists_per_day');
    GraphPerDay.load('#user_visits_per_day', '/admin/stats/user_visits_per_day');
    GraphPerDay.load('#favorites_per_day', '/admin/stats/favorites_per_day');
    GraphPerDay.load('#art_pieces_per_day', '/admin/stats/art_pieces_per_day');
    GraphPerDay.load('#os_signups', '/admin/stats/os_signups');
    PlainGraph.load('#art_piece_histogram', '/admin/stats/art_pieces_count_histogram');
    C3Graph.load('#art_pieces_histogram', '/admin/stats/art_pieces_count_histogram');

  } // end if we're on the admin page with graphs
});
