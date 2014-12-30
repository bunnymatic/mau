$ ->
  $('.nav a[data-toggle=tab]').on 'shown.bs.tab hidden.bs.tab', (ev) ->
    console.log ev
    anyActive = ($('.tab-pane.active').length != 0)
    $('.sidenav .tab-content').toggleClass('active', anyActive)
  $('.sidenav .tab-content').not('a').on 'click', ->
    $(".sidenav .active").removeClass('active')
    
  $('.nav .nav-mobile').on 'click', (ev) ->
    ev.preventDefault();
    ev.stopPropagation();
    $(@).closest('.nav').find('.tab-content, .tab-pane').toggleClass('active')

