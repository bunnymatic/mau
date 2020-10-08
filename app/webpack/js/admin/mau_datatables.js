import dt from "datatables";

const DATATABLES_CONFIG = {
  artists_index: {
    order: [[3, "desc"]],
  },
};

const DEFAULT_OPTIONS = {
  aaSorting: [],
  paging: false,
  info: false,
};

class MauDatatables {
  constructor(jQuery) {
    this.jQuery = jQuery;
    dt(window, jQuery);
  }

  config(pageKey) {
    return DATATABLES_CONFIG[pageKey] || {};
  }

  datatablesAvailable() {
    return !!this.jQuery.fn.dataTable;
  }

  isSearchableTable(_idx, el) {
    return !this.jQuery(el).hasClass("js-data-tables-no-search");
  }

  isNotSearchableTable(idx, el) {
    return !this.isSearchableTable(idx, el);
  }

  setupDataTables(selector) {
    if (!this.datatablesAvailable()) {
      return;
    }
    const cfg = this.config;
    const jq = this.jQuery;
    this.jQuery(selector)
      .filter(this.isSearchableTable.bind(this))
      .each((_idx, el) => {
        const $table = jq(el);
        const opts = { ...DEFAULT_OPTIONS, ...cfg($table.attr("id")) };
        jq($table).dataTable(opts);
      });

    this.jQuery(selector)
      .filter(this.isNotSearchableTable.bind(this))
      .each((_idx, el) => {
        var $table, opts;
        $table = jq(el);
        opts = {
          ...DEFAULT_OPTIONS,
          ...cfg($table.attr("id")),
          searching: false,
        };
        jq($table).dataTable(opts);
      });
  }
}
export default MauDatatables;
