/*global  */
/* mau admin js */

jQuery(function() {

  if (jQuery('body.admin .graph').length) {
    function dateFormatter(ts) {
      var date = new Date(0);
      var momentDate = moment(date.setSeconds(ts));
      return momentDate.format('YYYY-MM-DD');
    };

    var DEFAULT_COLOR = '#c39f06';

    var GraphPerDay = {
      load: function(selector, dataurl, seriesName) {
        seriesName = seriesName || 'data';
        jQuery.ajax({
          url:dataurl,
          method: 'get',
          success: function(data, status, xhr) {
            if (data && data.length) {
              var timestamp = data.map(function(entry) { return entry[0]; });
              var values = data.map(function(entry) { return entry[1]; });
              var columns = [
                ['x'].concat(timestamp),
                [seriesName].concat(values)
              ];
              colors = {}
              colors[seriesName] = DEFAULT_COLOR;
              var chart = c3.generate({
                bindto: selector,
                data: {
                  x: 'x',
                  type: 'bar',
                  columns: columns,
                  colors: colors
                },
                axis: {
                  y: {
                    label: {
                      position: 'outer-center',
                    },
                    tick: {
                      format: d3.format("d")
                    }
                  },
                  x: {
                    tick: {
                      format: dateFormatter,
                      rotate: 90,
                      centered: true,
                      fit: true
                    },
                    label: {
                      position: 'outer-center'
                    }
                  }
                },
                bar: {
                  width: {
                    ratio: 0.05 // this makes bar width 50% of length between ticks
                  }
                }
              });
            }
          }
        });
      }
    };

    var PlainGraph = {
      load: function(selector, dataurl) {
        jQuery.ajax({
          url: dataurl,
          method: 'get',
          success: function( data, status, xhr) {
            if (data && data.length) {
              var chart = c3.generate({
                bindto: selector,
                data: {
                  columns: [
                    ['# pieces'].concat(data.map(function(entry) { return entry[1]; }))
                  ],
                  type: 'bar',
                  colors: {
                    '# pieces': DEFAULT_COLOR
                  }
                },
                axis: {
                  y: {
                    max: 20,
                    label: {
                      position: 'outer-center',
                      text: '# artists'
                    }
                  },
                  x: {
                    label: {
                      position: 'outer-center'
                    }
                  }
                },
                bar: {
                  width: {
                    ratio: 0.9 // this makes bar width 50% of length between ticks
                  }
                }
              });
            }
          }
        });
      }
    }

    GraphPerDay.load('#artists_per_day', '/admin/stats/artists_per_day', 'artists');
    GraphPerDay.load('#user_visits_per_day', '/admin/stats/user_visits_per_day', 'visits');
    GraphPerDay.load('#favorites_per_day', '/admin/stats/favorites_per_day', 'favorites');
    GraphPerDay.load('#art_pieces_per_day', '/admin/stats/art_pieces_per_day', 'pieces');
    GraphPerDay.load('#os_signups', '/admin/stats/os_signups', 'sign ups');
    PlainGraph.load('#art_pieces_histogram', '/admin/stats/art_pieces_count_histogram');

  } // end if we're on the admin page with graphs
});
