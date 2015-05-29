jQuery ->

 CHOOSER = '#account_type_chooser'

 $chooser = jQuery(CHOOSER).bind 'change', () ->
   newform = jQuery(CHOOSER).val()
   uri_parser = new MAU.QueryStringParser("/users/new")
   uri_parser.query_params.type = newform
   spinner = new MAU.Spinner()
   spinner.spin()
   window.location.href = uri_parser.toString()
