MAU = window.MAU = window.MAU || {}

MAU.SpinnerOptions =
  color: "#5a636a" # $xmediumgray from colors.scss
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
    @el = $(@opts.element || "#spinner")[0];
    @spinOpts = _.extend {}, MAU.SpinnerOptions, @opts

  spin: ->
    @spinner = new Spinner(@spinOpts) unless @spinner
    @spinner.spin(@el)
  stop: ->
    @spinner.stop() if @spinner
