jQuery(function() {
  jQuery('.event_nav .by_month').each(function(nav_el) {
    nav_el.observe('click', function(el) {

      jQuery('.event_nav .by_month').each(function(el) { el.removeClass('current'); });

      this.addClass('current');

      jQuery('.event_list .events_by_month').each(function(el) {
        el.removeClass('current');
      });

      jQuery('.event_list .events_by_month.'+ this.data('viskey')).each(function(el) {
        el.addClass('current');
      });
    });
  });

  pickadateEl = jQuery('.pickadate');
  if (pickadateEl.pickadate) { pickadateEl.pickadate(); }
  pickatimeEl = jQuery('.pickatime');
  if (pickatimeEl.pickatime) { pickatimeEl.pickatime(); }
});
