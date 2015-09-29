$ ->
  $('#donate_for_openstudios').on 'click', (ev) ->
    ev.preventDefault();
    $('#paypal_donate_openstudios').submit();
