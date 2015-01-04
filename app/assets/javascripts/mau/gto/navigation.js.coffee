$ ->
  hideTabs = ->
    $(".sidenav .active").removeClass('active')
    $(".tab-content").removeClass('active')    
    
  $('.nav a[data-toggle=tab]').on 'click', (ev) ->
    # toggle tab if the click is on the active one
    activeTab = $('.tab-content ul.active').attr('id')
    if activeTab == $(this).attr('href').substr(1)
      ev.preventDefault();
      ev.stopPropagation();
      hideTabs()

  $('.nav a[data-toggle=tab]').on 'shown.bs.tab hidden.bs.tab', (ev) ->
    anyActive = ($('.tab-pane.active').length != 0)
    $('.sidenav .tab-content').toggleClass('active', anyActive)

  $('.sidenav .tab-content').not('a').on 'click', (ev) ->
    # if we're following a link, don't close everything, just follow it
    if ev.target.tagName != 'A'
      ev.preventDefault();
      ev.stopPropagation();
      hideTabs()
    
  $('.nav .nav-mobile').on 'click', (ev) ->
    ev.preventDefault();
    ev.stopPropagation();
    $(@).closest('.nav').find('.tab-content, .tab-pane').toggleClass('active')

