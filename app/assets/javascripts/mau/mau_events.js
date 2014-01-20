var MAU = window.MAU = window.MAU || {};
jQuery(function() {
  $$('.event_nav .by_month').each(function(nav_el) {
    nav_el.observe('click', function(el) {
      $$('.event_nav .by_month').each(function(el) { el.removeClassName('current'); });
      this.addClassName('current');

      $$('.event_list .events_by_month').each(function(el) {
        el.removeClassName('current');
      });

      $$('.event_list .events_by_month.'+ this.data('viskey')).each(function(el) {
        el.addClassName('current');
      });
    });
  });

  jQuery('.pickadate').pickadate();
});
