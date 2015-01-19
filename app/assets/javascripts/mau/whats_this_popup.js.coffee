MAU = window.MAU = window.MAU || {}
MAU.WhatsThis = class WhatsThis
  constructor: (trigger) ->
    @trigger = trigger
    $trigger = jQuery(@trigger)
    @parentId = $trigger.data('parent')
    @section = $trigger.data('section')
    @helpTextDiv = '#' + @parentId + "container"

    jQuery(@trigger).bind('click', @popup)
    jQuery(@helpTextDiv).bind('click', @popup)

  popup: =>
    # gto
    jQuery(@helpTextDiv).toggleClass('active');
    # the old way
    #jQuery(@helpTextDiv).fadeToggle()

jQuery ->
  jQuery('.js-help').each ->
    new MAU.WhatsThis(this)
