(function() {
  var MAU, QueryStringParser;

  MAU = window.MAU = window.MAU || {};

  MAU.QueryStringParser = QueryStringParser = (function() {

    function QueryStringParser(url) {
      var parser, _that;
      this.query_params = {};
      if (!document || !document.createElement) {
        throw 'This needs to be run in an HTML context with a document.';
      }
      parser = document.createElement('a');
      parser.href = url;
      this.url = url;
      if (parser.origin) {
        this.origin = parser.origin;
      } else {
        this.origin = [parser.protocol, '//', parser.host].join('');
      }
      this.protocol = parser.protocol;
      this.pathname = parser.pathname;
      this.hash = parser.hash;
      _that = this;
      _.each(parser.search.substr(1).split('&'), function(params) {
        var kv;
        kv = params.split('=');
        return _that.query_params[kv[0]] = kv[1];
      });
    }

    QueryStringParser.prototype.toString = function() {
      var bits, q;
      q = _.compact(_.map(this.query_params, function(v, k) {
        if ((typeof v !== 'undefined') && (v !== null)) {
          return [k, v].join('=');
        }
      })).join('&');
      bits = [this.origin, this.pathname].join('');
      if (q) {
        bits += "?" + q;
      }
      if (this.hash) {
        bits += this.hash;
      }
      return bits;
    };

    return QueryStringParser;

  })();

}).call(this);
