$ ->
  navHelpers =
    hideTabs: ->
      $(".sidenav .active").removeClass('active')
      $(".tab-content").removeClass('active')
    setActiveSection: ->
      path = location.pathname.replace(/\#.*$/, '')
      $('.nav a[href="' + path + location.search + '"]').closest('.tab').addClass('active')
      
  $('.nav a[data-toggle=tab]').on 'click', (ev) ->
    # toggle tab if the click is on the active one
    activeTab = $('.tab-content ul.active').attr('id')
    if activeTab == $(this).attr('href').substr(1)
      ev.preventDefault()
      ev.stopPropagation()
      navHelpers.hideTabs()

  $('.nav a[data-toggle=tab]').on 'shown.bs.tab hidden.bs.tab', (ev) ->
    anyActive = ($('.tab-pane.active').length != 0)
    $('.sidenav .tab-content').toggleClass('active', anyActive)
    if anyActive
      MAU.Search.closeSearch()

  $('.sidenav .tab-content').not('a').on 'click', (ev) ->
    # if we're following a link, don't close everything, just follow it
    if ev.target.tagName != 'A'
      ev.preventDefault()
      ev.stopPropagation()
      navHelpers.hideTabs()
    
  $('.nav .js-nav-mobile, .tab-content .js-close').on 'click', (ev) ->
    ev.preventDefault()
    ev.stopPropagation()
    $(@).closest('.nav').find('.tab-content, .tab-pane').toggleClass('active')

  $('.js-close').on 'click', (ev) ->
    $(@).closest('.tab-content').removeClass('active', false)

  navHelpers.setActiveSection();


  window.MAU ||= {}
  MAU.Navigation ||= {}
  MAU.Navigation = _.extend({}, MAU.Navigation, navHelpers);
  
