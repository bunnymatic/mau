const hashToQueryString = function (hash) {
  const queryParams = new URLSearchParams();

  Object.entries(hash).forEach(([k, v]) => {
    if (typeof v !== "undefined" && v !== null) {
      queryParams.append(k, v);
    }
  });
  return queryParams.toString();
};

const queryStringToHash = function (query) {
  const queryParams = new URLSearchParams(query);
  const hash = {};
  for (const [k, v] of queryParams.entries()) {
    hash[k] = v;
  }
  return hash;
};

class QueryStringParser {
  constructor(url) {
    this._url = new URL(url);
  }

  get hash() {
    return this._url.hash;
  }

  get protocol() {
    return this._url.protocol;
  }

  get pathname() {
    return this._url.pathname;
  }

  get url() {
    return this._url.toString();
  }

  get origin() {
    return this._url.origin;
  }

  get queryParams() {
    const hash = {};
    for (const [k, v] of this._url.searchParams.entries()) {
      hash[k] = v;
    }
    return hash;
  }

  append(k, v) {
    this._url.searchParams.append(k, v);
  }

  delete(k) {
    this._url.searchParams.delete(k);
  }

  toString() {
    return this._url.toString();
  }
}

export { hashToQueryString, queryStringToHash };
export default QueryStringParser;
