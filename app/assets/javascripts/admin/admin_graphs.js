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
        noTicks: xticks, max: new Date().valueOf()/1000
      },
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
            if (data) {
              var timestamp = data.map(function(entry) { return entry[0]; });
              var values = data.map(function(entry) { return entry[1]; });
              var columns = [
                ['x'].concat(timestamp),
                ['data'].concat(values)
              ];
              var chart = c3.generate({
                bindto: selector,
                data: {
                  x: 'x',
                  type: 'bar',
                  columns: columns,
                  colors: {
                    'data': '#d7682b'
                  }
                },
                axis: {
                  y: {
                    label: {
                      position: 'outer-center',
                    }
                  },
                  x: {
                    tick: {
                      format: function(ts) {
                        var date = new Date(0);
                        var momentDate = moment(date.setSeconds(ts));
                        return momentDate.format('YYYY-MM-DD');
                      },
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
            if (data) {
              var chart = c3.generate({
                bindto: selector,
                data: {
                  columns: [
                    ['# pieces'].concat(data.map(function(entry) { return entry[1]; }))
                  ],
                  type: 'bar',
                  colors: {
                    '# pieces': '#d7682b'
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

    GraphPerDay.load('#artists_per_day', '/admin/stats/artists_per_day');
    GraphPerDay.load('#user_visits_per_day', '/admin/stats/user_visits_per_day');
    GraphPerDay.load('#favorites_per_day', '/admin/stats/favorites_per_day');
    GraphPerDay.load('#art_pieces_per_day', '/admin/stats/art_pieces_per_day');
    GraphPerDay.load('#os_signups', '/admin/stats/os_signups');
    PlainGraph.load('#art_pieces_histogram', '/admin/stats/art_pieces_count_histogram');

  } // end if we're on the admin page with graphs
});
