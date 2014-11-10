MAU = window.MAU = window.MAU || {}

MAU.QueryStringParser = class QueryStringParser
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
    _that = this
    _.each parser.search.substr(1).split('&'), (params) ->
      kv = params.split('=')
      _that.query_params[kv[0]] = kv[1]

  toString: ->
    q = _.compact(_.map(@query_params, (v,k) ->
      if (typeof v != 'undefined') && (v != null)
        [k,v].join('=')
    )).join('&')

    bits = [ @origin, @pathname ].join('')
    if q
      bits += "?" + q
    if @hash
      bits += @hash
    bits
