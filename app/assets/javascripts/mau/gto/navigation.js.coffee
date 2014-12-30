$ ->
  $('.nav a[data-toggle=tab]').on 'shown.bs.tab', (ev) ->
    console.log ev.target
    console.log ev.currentTarget
    console.log @
  $('.nav .nav-mobile').on 'click', (ev) ->
    ev.preventDefault();
    ev.stopPropagation();
    $(@).closest('.nav').find('.tab-pane').toggleClass('active')
  $('.nav').on 'click', (ev) ->
    $(@).removeClass('mobile-open')
