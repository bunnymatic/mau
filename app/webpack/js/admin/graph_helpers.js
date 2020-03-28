import jQuery from "jquery";
import c3 from "c3";
import { format } from "d3-format";
import moment from "moment";
import { get } from "@js/mau_ajax";

function dateFromSeconds(seconds) {
  const date = new Date(0);
  date.setSeconds(seconds);
  return date;
}

function dateFormatter(ts) {
  return moment(dateFromSeconds(ts)).format("YYYY-MM-DD");
}

function appendNoDataMessage(selector) {
  jQuery(selector).append(
    jQuery("<div>", { class: "graph--empty" }).html("Nothing to see here...")
  );
}

const DEFAULT_COLOR = "#c39f06";

const firstEntry = (entry) => entry[0];
const secondEntry = (entry) => entry[1];

export const GraphPerDay = {
  load: function (selector, dataurl, seriesName) {
    seriesName = seriesName || "data";

    const onSuccess = function (data, _status, _xhr) {
      if (!data || !data.length) {
        appendNoDataMessage(selector);
        return;
      }

      const timestamp = data.map(firstEntry);
      const values = data.map(secondEntry);

      const columns = [["x"].concat(timestamp), [seriesName].concat(values)];
      const colors = {
        [seriesName]: DEFAULT_COLOR,
      };

      const range = {
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
              format: format("d"),
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

    get(dataurl).done(onSuccess);
  },
};

export const PlainGraph = {
  load: function (selector, dataurl, xAxisLabel, yAxisLabel) {
    const onSuccess = function (data, _status, _xhr) {
      if (!data || !data.length) {
        appendNoDataMessage(selector);
        return;
      }
      c3.generate({
        bindto: selector,
        data: {
          columns: [[xAxisLabel].concat(data.map(secondEntry))],
          type: "bar",
          colors: {
            [xAxisLabel]: DEFAULT_COLOR,
          },
        },
        axis: {
          y: {
            label: {
              position: "outer-center",
              text: yAxisLabel,
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
    get(dataurl).done(onSuccess);
  },
};
