/** jquery mods **/
jQuery(function() {
  /** arrange art */
  var sortMe = jQuery('#arrange_art .sortable')
  if (sortMe.sortable) { sortMe.sortable(); }

  jQuery('#arrange_art_form').bind('submit', function(ev) {
    // construct new order
    var divs = jQuery('.artp-thumb-container');
    var newOrderArray = divs.map(function() {
      return parseInt( jQuery(this).attr('pid'),10 );
    });
    var newOrder = newOrderArray.get().join(',');
    jQuery(this).append( jQuery('<input>', {type:"hidden", name:'neworder', value:newOrder }) );
  });


});
