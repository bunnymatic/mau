jQuery.hideableRowsDefaults =
  rowSelector: 'table tbody tr'
  whatToHideSelectors: '.hide-rows input'
  
jQuery.fn.hideableRows = (method) ->
  that = this
  inArgs = arguments
  methods =
    init: (options) ->
      o = _.extend({},jQuery.hideableRowsDefaults, options)
      jQuery(@).on 'click', o.whatToHideSelectors, (ev) ->
        clz = this.value
        hide = !this.checked
        jQuery(that).find(o.rowSelector + '.'+clz).toggleClass('js-hidden-row')
       
  this.each () ->
    # Method calling logic
    if ( methods[method] )
      return methods[ method ].apply( this, Array.prototype.slice.call( inArgs, 1 ));
    else if ( typeof method == 'object' || ! method )
      return methods.init.apply( this, inArgs );
    else
      $.error( 'Method ' +  method + ' does not exist on jQuery.hideableRows' );


    # $$('.hide-rows input').each(function(el) {
    #   el.observe('click', function() {
    #     var clz = this.value;
    #     var show = this.checked;
    #     $$('table.admin-table tr.' + clz).each(function(row) {
    #       if (show) {
    #         row.fade();
    #       } else {
    #         row.appear();
    #       }
    #     });
    #   });
    # });
      
