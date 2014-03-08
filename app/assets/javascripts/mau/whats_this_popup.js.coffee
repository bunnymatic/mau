MAU = window.MAU = window.MAU || {}
MAU.WhatsThis = class WhatsThis
  constructor: (trigger) ->
    @trigger = trigger
    $trigger = jQuery(@trigger)
    @parentId = $trigger.data('parent')
    @section = $trigger.data('section')
    @helpTextDiv = '#' + @parentId + "container"

    jQuery(@trigger).bind('click', @popup)
    jQuery(@helpTextDiv).find('.popup-close').bind('click', @popup)
    
  popup: =>
    jQuery(@helpTextDiv).fadeToggle()

jQuery ->
  jQuery('.js-help').each ->
    new MAU.WhatsThis(this)
