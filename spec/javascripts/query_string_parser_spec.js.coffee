describe 'MAU.QueryStringParser', ->

  beforeEach ->
    @url = 'http://this.com/path/subpath?a=1&b=2&c=%2Fprojects%2Fmau%2Fspec%2F#ABC'
    @parser = new MAU.QueryStringParser(@url)

  describe '#constructor', ->
    it "provides access to url", ->
      expect(@parser.url).toEqual(@url)
    it "provides access to origin", ->
      expect(@parser.origin).toEqual('http://this.com')
    it "provides access to protocol", ->
      expect(@parser.protocol).toEqual('http:')
    it "provides access to hash", ->
      expect(@parser.hash).toEqual('#ABC')
    it "provides access to pathname", ->
      expect(@parser.pathname).toEqual('/path/subpath')
    it "provides access to query params", ->
      expect(@parser.query_params).toEqual({
        a: '1'
        b: '2'
        c: '%2Fprojects%2Fmau%2Fspec%2F'
      })
  describe '#toString', ->
    it "reconstitutes the url properly", ->
      @parser.query_params['blue'] = 'red'
      delete @parser.query_params['c']
      s = @parser.toString()
      expect(s).toContain('a=1')
      expect(s).toContain('b=2')
      expect(s).toContain('blue=red')
      expect(s).not.toContain('c=')
      expect(s).toContain('#ABC')
      expect(s).toContain('http://this.com/path/subpath?')
