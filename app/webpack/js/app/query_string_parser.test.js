import { expect } from "vitest";

import QueryStringParser, {
  hashToQueryString,
  queryStringToHash,
} from "./query_string_parser";

describe("hashToQueryString", () => {
  it("converts hash to query string", () => {
    expect(hashToQueryString({ x: "xval", y: null, z: "zval" })).toEqual(
      "x=xval&z=zval"
    );
  });
});

describe("queryStringToHash", () => {
  it("converts query string to hash", () => {
    expect(queryStringToHash("x=xval&z=zval&y=")).toEqual({
      x: "xval",
      z: "zval",
      y: "",
    });
  });
});

describe("QueryStringParser", function () {
  let url, parser;
  beforeEach(function () {
    url =
      "http://this.com/path/subpath?a=1&b=2&c=%2Fprojects%2Fmau%2Fspec%2F#ABC";
    parser = new QueryStringParser(url);
  });
  describe("#constructor", function () {
    it("provides access to url", function () {
      expect(parser.url).toEqual(url);
    });
    it("provides access to origin", function () {
      expect(parser.origin).toEqual("http://this.com");
    });
    it("provides access to protocol", function () {
      expect(parser.protocol).toEqual("http:");
    });
    it("provides access to hash", function () {
      expect(parser.hash).toEqual("#ABC");
    });
    it("provides access to pathname", function () {
      expect(parser.pathname).toEqual("/path/subpath");
    });
    it("provides access to query params", function () {
      expect(parser.queryParams).toEqual({
        a: "1",
        b: "2",
        c: "/projects/mau/spec/",
      });
    });
  });
  describe("#toString", function () {
    it("reconstitutes the url properly", function () {
      var s;
      parser.append("blue", "red");
      parser.delete("c");
      s = parser.toString();
      expect(s).toContain("a=1");
      expect(s).toContain("b=2");
      expect(s).toContain("blue=red");
      expect(s).not.toContain("c=");
      expect(s).toContain("#ABC");
      expect(s).toContain("http://this.com/path/subpath?");
    });
  });
});
