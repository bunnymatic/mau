MAU = window.MAU = window.MAU || {}

MAU.SpinnerOptions =
  lines: 13
  length: 30
  width: 14
  radius: 40
  corners: 1
  rotate: 0
  direction: 1
  speed: 1
  trail: 60
  shadow: false
  hwaccel: false
  className: 'spinner'
  zIndex: 2e9
  top: '250px'


MAU.Spinner = class MAUSpinner
  constructor: (opts) ->
    @opts = opts || {}
    @el = opts.element || '#spinner'
    opts.element = null
    @spinOpts = _.extend {}, MAU.SpinnerOptions, opts

  spin: ->
    console.log(@spinOpts)
    jQuery(@el).spin @spinOpts
  stop: ->
    jQuery(@el).spin false
  
  
