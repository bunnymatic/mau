# collapse events on header click

jQuery ->
  jQuery('body.events .events').on 'click', '.event header', (ev) ->
    jQuery(this).closest('.event').toggleClass('open');

