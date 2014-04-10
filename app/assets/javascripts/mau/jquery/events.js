jQuery(function() {
  jQuery('.event_nav .by_month').bind('click', function(ev) {
    el = jQuery(this)

    jQuery('.event_nav .by_month').removeClass('current');
    el.addClass('current');

    jQuery('.event_list .events_by_month').removeClass('current');

    jQuery('.event_list .events_by_month.'+ el.data('viskey')).addClass('current');
  });

  pickadateEl = jQuery('.pickadate');
  if (pickadateEl.pickadate) { pickadateEl.pickadate(); }
  pickatimeEl = jQuery('.pickatime');
  if (pickatimeEl.pickatime) { pickatimeEl.pickatime(); }
});
