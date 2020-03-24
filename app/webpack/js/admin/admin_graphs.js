import jQuery from "jquery";

(function () {
  jQuery(function () {
    var DEFAULT_COLOR = "#c39f06";

    function dateFromSeconds(seconds) {
      var date = new Date(0);
      date.setSeconds(seconds);
      return date;
    }

    function dateFormatter(ts) {
      return moment(dateFromSeconds(ts)).format("YYYY-MM-DD");
    }

    function appendNoDataMessage(selector) {
      jQuery(selector).append(
        jQuery("<div>", { class: "graph--empty" }).html(
          "Nothing to see here..."
        )
      );
    }

    if (jQuery("body.admin .graph").length) {
      var GraphPerDay = {
        load: function (selector, dataurl, seriesName) {
          seriesName = seriesName || "data";

          var onSuccess = function (data, _status, _xhr) {
            if (!data || !data.length) {
              appendNoDataMessage(selector);
              return;
            }

            var timestamp = data.map(function (entry) {
              return entry[0];
            });
            var values = data.map(function (entry) {
              return entry[1];
            });
            var columns = [
              ["x"].concat(timestamp),
              [seriesName].concat(values),
            ];
            var colors = {};
            colors[seriesName] = DEFAULT_COLOR;
            var range = {
              min: dateFromSeconds(timestamp[0]),
              max: dateFromSeconds(timestamp[timestamp.length - 1]),
            };
            c3.generate({
              bindto: selector,
              data: {
                x: "x",
                type: "bar",
                columns: columns,
                colors: colors,
              },
              axis: {
                y: {
                  label: {
                    position: "outer-center",
                  },
                  tick: {
                    format: d3.format("d"),
                  },
                },
                x: {
                  type: "timeseries",
                  range: range,
                  tick: {
                    format: dateFormatter,
                    rotate: 90,
                    fit: false,
                  },
                },
              },
              bar: {
                width: {
                  ratio: 0.1, // this makes bar width 50% of length between ticks
                },
              },
            });
          };

          jQuery
            .ajax({
              url: dataurl,
              method: "get",
            })
            .done(onSuccess);
        },
      };

      var PlainGraph = {
        load: function (selector, dataurl) {
          var onSuccess = function (data, _status, _xhr) {
            if (!data || !data.length) {
              appendNoDataMessage(selector);
              return;
            }
            c3.generate({
              bindto: selector,
              data: {
                columns: [
                  ["# pieces"].concat(
                    data.map(function (entry) {
                      return entry[1];
                    })
                  ),
                ],
                type: "bar",
                colors: {
                  "# pieces": DEFAULT_COLOR,
                },
              },
              axis: {
                y: {
                  label: {
                    position: "outer-center",
                    text: "# artists",
                  },
                },
                x: {
                  max: 20,
                  label: {
                    position: "outer-center",
                  },
                },
              },
              bar: {
                width: {
                  ratio: 0.9, // this makes bar width 50% of length between ticks
                },
              },
            });
          };
          jQuery
            .ajax({
              url: dataurl,
              method: "get",
            })
            .done(onSuccess);
        },
      };

      GraphPerDay.load(
        "#artists_per_day",
        "/admin/stats/artists_per_day",
        "artists"
      );
      GraphPerDay.load(
        "#user_visits_per_day",
        "/admin/stats/user_visits_per_day",
        "visits"
      );
      GraphPerDay.load(
        "#favorites_per_day",
        "/admin/stats/favorites_per_day",
        "favorites"
      );
      GraphPerDay.load(
        "#art_pieces_per_day",
        "/admin/stats/art_pieces_per_day",
        "pieces"
      );
      GraphPerDay.load("#os_signups", "/admin/stats/os_signups", "sign ups");
      PlainGraph.load(
        "#art_pieces_histogram",
        "/admin/stats/art_pieces_count_histogram"
      );
    } // end if we're on the admin page with graphs
  });
}.call(this));
