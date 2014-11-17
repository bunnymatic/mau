$ ->
  $('.nav .nav-mobile').on 'click', (ev) ->
    ev.preventDefault();
    ev.stopPropagation();
    $(@).closest('.nav').toggleClass('mobile-open')
  $('.nav').on 'click', (ev) ->
    $(@).removeClass('mobile-open')
