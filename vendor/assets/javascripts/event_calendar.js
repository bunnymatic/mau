/*
 * Smart event highlighting
 * Handles for when events span rows, or don't have a background color
 */

 jQuery(document).ready(function() {
  var highlight_color = "#738294";

  // replace >> << with raquo and laquo
  jQuery('.ec-month-nav').each(function() {
    var elementHtml = jQuery(this).html();
    elementHtml = elementHtml.replace('&lt;&lt; ', '&laquo; ').replace(' &gt;&gt;', ' &raquo;');
    jQuery(this).html(elementHtml);
  });

  // highlight events that have a background color
  jQuery('.ec-event-bg').each(function() {
    jQuery(this).bind('mouseover', function() {
      var eventId = jQuery(this).data('event-id')
      var className = '.ec-event-' + eventId;
      jQuery(className).css({backgroundColor: highlight_color});
    })
    jQuery(this).bind('mouseout', function() {
      var event_color = jQuery(this).data('color')
      var eventId = jQuery(this).data('event-id');
      var className = '.ec-event-' + eventId;
      jQuery(className).css({backgroundColor: event_color});
    })
  });
});
