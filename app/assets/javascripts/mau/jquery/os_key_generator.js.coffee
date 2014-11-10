MAU = window.MAU = window.MAU || {}

# attach this plugin to a form with start_date, end_date and key inputs
MAU.OsKeyGenerator = class OsKeyGenerator

  updateKey: (ev) =>
    startDate = moment(@startDate.val())
    if startDate.isValid()
      key = startDate.format('YYYYMM')
      @key.val(key)

  constructor: (element, opts) ->
    @element = $(element)
    @opts = _.extend({},{
      start_date_field: '#open_studios_event_start_date'
      end_date_field: '#open_studios_event_start_date'
      key_field: '#open_studios_event_key'
    }, opts)

    @startDate = @element.find(@opts.start_date_field)
    @endDate = @element.find(@opts.end_date_field)
    @key = @element.find(@opts.key_field)

    @startDate.on 'change', @updateKey
    @endDate.on 'change', @updateKey

    @updateKey()


