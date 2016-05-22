# To use, setup some dom like this
#
#
# <div id='hideable-row-widget'>
#   <fieldset class='hide-rows'>
#     Checkboxes to filter (hide) rows
#     where value is the class used to find and hide/show the row
#     <input type='checkbox' value='filter1'>
#     <input type='checkbox' value='filter2'>
#   </fieldset>
#
#   <table>
#     <tbody>
#       <tr class="filter1"> </tr>
#       <tr class="filter2"> </tr>
#       <tr class="filter1"> </tr>
#       <tr class="filter2"> </tr>
#     </tbody>
#   <table>
# </div>
#
# then init with jQuery('#hideable-row-widget')
#
# when filter1 is checked, all the rows with class filter1 will be hidden
#
# options (with defaults)
#   row: 'table tbody tr'
#   whatToHideSelectors: '.hide-rows input'
#
# row is to define the item to show/hide
# whatToHideSelectors defines the location of the inputs which should be
#   checkboxes whose value is the CSS class used for filtering

jQuery.hideableRowsDefaults =
  row: 'table tbody tr'              # what contains the items to show/hide
  whatToHideSelectors: '.hide-rows input'  # where do we find the class selectors to hide (checkboxes)


jQuery.fn.hideableRows = (method) ->
  that = this
  inArgs = arguments

  hasAnyClass = (item, classes) ->
    for c in classes
      return true if jQuery(item).hasClass(c)
    false

  getCheckedClasses = (container, opts) ->
    _.compact(_.map jQuery(container).find(opts.whatToHideSelectors), (item) ->  jQuery(item).is(':checked') && jQuery(item).val())


  toggleItems = (container, opts) ->
    checkedClasses = getCheckedClasses(container,opts)
    jQuery(that).find(opts.row).each (idx, row) ->
      $row = jQuery(row)
      hide = hasAnyClass(row, checkedClasses)
      $row.toggleClass('js-hidden-row', hide)



  methods =
    init: (options) ->
      o = _.extend({},jQuery.hideableRowsDefaults, options)
      jQuery(@).on 'click', o.whatToHideSelectors, (ev) =>
        toggleItems(@, o)

  this.each () ->
    # Method calling logic
    if ( methods[method] )
      return methods[ method ].apply( this, Array.prototype.slice.call( inArgs, 1 ));
    else if ( typeof method == 'object' || ! method )
      return methods.init.apply( this, inArgs );
    else
      $.error( 'Method ' +  method + ' does not exist on jQuery.hideableRows' );
