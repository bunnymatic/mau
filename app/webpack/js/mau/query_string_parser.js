import map from "lodash/map";
import reduce from "lodash/reduce";

const hashToQueryString = function (hash) {
  return map(hash, function (v, k) {
    if (typeof v !== "undefined" && v !== null) {
      return [k, v].join("=");
    }
  })
    .filter((x) => !!x)
    .join("&");
};

const queryStringToHash = function (query) {
  return reduce(
    query.split("&"),
    function (memo, params) {
      var kv;
      kv = params.split("=");
      memo[kv[0]] = kv[1];
      return memo;
    },
    {}
  );
};

class QueryStringParser {
  constructor(url) {
    var parser, queryString;
    this.query_params = {};
    if (!document || !document.createElement) {
      throw "This needs to be run in an HTML context with a document.";
    }
    parser = document.createElement("a");
    parser.href = url;
    this.url = url;
    if (parser.origin) {
      this.origin = parser.origin;
    } else {
      this.origin = [parser.protocol, "//", parser.host].join("");
    }
    this.protocol = parser.protocol;
    this.pathname = parser.pathname;
    this.hash = parser.hash;
    queryString = parser.search.substr(1);
    this.query_params = queryStringToHash(queryString);
  }

  toString() {
    var bits, q;
    q = hashToQueryString(this.query_params);
    bits = [this.origin, this.pathname].join("");
    if (q) {
      bits += "?" + q;
    }
    if (this.hash) {
      bits += this.hash;
    }
    return bits;
  }
}

export { queryStringToHash, hashToQueryString };
export default QueryStringParser;
