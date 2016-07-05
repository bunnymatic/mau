MAU = window.MAU = window.MAU || {}

MAU.QueryStringParserHelpers =
  hashToQueryString: (hash) ->
    _.compact(_.map(hash, (v,k) ->
      if (typeof v != 'undefined') && (v != null)
        [k,v].join('=')
    )).join('&')
  queryStringToHash: (query) ->
    _.reduce(query.split('&'), (memo, params) ->
      kv = params.split('=')
      memo[kv[0]] = kv[1]
      memo
    ,
    {})

MAU.QueryStringParser = class QueryStringParser
  util = MAU.QueryStringParserHelpers
  constructor: (url) ->
    @query_params = {}
    if !document || !document.createElement
      throw 'This needs to be run in an HTML context with a document.'
    parser = document.createElement('a')
    parser.href = url
    @url = url
    if (parser.origin)
      @origin = parser.origin
    else
      @origin = [parser.protocol, '//', parser.host].join('')
    @protocol = parser.protocol
    @pathname = parser.pathname
    @hash = parser.hash
    queryString = parser.search.substr(1)
    @query_params = util.queryStringToHash(queryString)

  toString: ->
    q = util.hashToQueryString(@query_params)

    bits = [ @origin, @pathname ].join('')
    if q
      bits += "?" + q
    if @hash
      bits += @hash
    bits
