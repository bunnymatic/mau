MAU = window.MAU = window.MAU || {}

MAU.SpinnerOptions =
  lines: 13
  length: 30
  width: 14
  radius: 40
  corners: 1
  rotate: 0
  direction: 1
  speed: 1
  trail: 60
  shadow: false
  hwaccel: false
  className: 'spinner'
  zIndex: 2e9
  top: '250px'

MAU.SearchPage = class MAUSearch

  sprite_minus_dom = '<div class="sprite minus" alt="hide" />'
  sprite_plus_dom = '<div class="sprite plus" alt="show" />'

  # initialize with checkbox container ids,
  # and the id of the box showing the current search params
  constructor: (chooserIds, currentSearch) ->
    @currentSearch = currentSearch
    @choosers = if !_.isArray(chooserIds) then [chooserIds] else chooserIds
    @dropdowns = '#os_artist'
    @checkboxSelector = '.cb_entry input[type=checkbox]'
    @searchFormSelector = 'form.power_search'
    @spinnerHook = '#spinner'
    _that = this
    jQuery ->
      _that.initExpandos()
      _that.initCBs()
      _that.initAnyLinks()
      _that.initOSChooser()
      _that.initFormSubmitOnChange()
      _that.initPaginator()


  # setup onchange for open studios dropdown
  initOSChooser: ->
    _that = this
    jQuery(@dropdowns).bind 'change', (ev) ->
      _that._submitForm();

  # intialize the a.reset links
  initAnyLinks: ->
    _that = this
    _.each @choosers, (container) ->
      c = jQuery(container)
      _that.setAnyLink(c)
      c.find('.reset a').bind 'click', (ev) ->
        cbs = c.find _that.checkboxSelector
        _.each cbs, (el) ->
          el.checked = false
        _that.setAnyLink(c)
        ev.stopPropagation();
        _that._submitForm();
        false

  # set a.reset links based on the checkbox content
  setAnyLink: (container) ->
    _that = this
    c = jQuery(container)
    if c.length
      cbs = c.find @checkboxSelector + ":checked"
      a = c.find('.reset a')
      if a.length
        a.toggle(cbs.length > 0)

  initFormSubmitOnChange: ->
    _that = this
    os_chooser = jQuery('os_artist')
    if os_chooser
      os_chooser.bind 'change', (ev) ->
        _that._submitForm(ev)

    _.each @choosers, (c) ->
      $c = jQuery(c)
      if $c
        s = ->
          _that._submitForm()
        debounced = s.debounce(500,false)
        _.each $c.find(_that.checkboxSelector), (item) ->
          jQuery(item).bind 'change', debounced


  initCBs: ->
    _that = this

    # if the first is checked, uncheck all others
    # if none are checked, check the first
    # if the first is checked and we check another, uncheck the first
    # click happens before the 'check' is registered on the checkbox
    # change happens after
    _.each @choosers, (c) ->
      $c = jQuery(c)
      if $c
        _.each $c.find(_that.checkboxSelector), (item,idx) ->
          jQuery(item).bind 'change', (ev) ->
            _that.setAnyLink(c)
        _that.setAnyLink(c)

  initExpandos: ->
    # expando based on
    #
    #  Written by Jonathan Callahan -
    # SourceCode: http://mazamascience.com/code/ShowHide/
    # Based On: http://onlinetools.org/tools/domcollapse/
    # Released under the MIT license:

    # Copyright (c) 2008 Jonathan Callahan

    # Permission is hereby granted, free of charge, to any person
    # obtaining a copy of this software and associated documentation
    # files (the "Software"), to deal in the Software without
    # restriction, including without limitation the rights to use,
    # copy, modify, merge, publish, distribute, sublicense, and/or sell
    # copies of the Software, and to permit persons to whom the
    # Software is furnished to do so, subject to the following
    # conditions:

    # The above copyright notice and this permission notice shall be
    # included in all copies or substantial portions of the Software.

    # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
    # EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
    # OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
    # NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
    # HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
    # WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
    # FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
    # OTHER DEALINGS IN THE SOFTWARE.
    _that = this
    col = jQuery('.column')
    col.on('click', '.trigger', _that.toggleTarget) if col.on
    triggers = jQuery('.column .trigger')
    _.each triggers, (item) ->
      item.insert sprite_minus_dom
      item.next().hide()
    expandeds = jQuery('.column .expanded')
    _.each expandeds, (item) ->
      item.insert sprite_plus_dom
      item.addClassName('trigger')

    # if we have the search form, bind ajax to the submit
    #
    searchForm = jQuery(@searchFormSelector)
    searchForm.bind 'submit', (ev) ->
      _that._submitForm(ev)
    false

  updateQueryParamsInView: ->
    _that = this
    # grab form params
    frm = jQuery(_that.searchFormSelector)
    if (frm.length)
      # get checked mediums
      ms = _.map frm.find('#medium_chooser input:checked'), (item) ->
        item.data('display')
      ss = _.map frm.find('#studio_chooser input:checked'), (item) ->
        item.data('display')
      os = null
      try
        os = frm.find('#os_artist').val()
      catch err
        os = null
        throw err
      kw = _.map frm.find('#keywords').val().split(","), (s) ->
        s.trim()

      ctx = jQuery('.current_search')
      if ctx.length
        # set keywords
        kw_block = ctx.find('.block.keywords ul.keywords')
        if kw_block.length
          kw_block.html('')
          _.each kw, (k,idx) ->
            s = k
            s = "AND " + s unless !idx
            li = jQuery('<li>').html(s)
            kw_block.append li
        # set mediums
        med_block = ctx.find('.block.mediums ul')
        if med_block.length
          med_block.html('')
          if ms.length
            _.each ms, (m) ->
              med_block.append jQuery('<li>').html(m)
          else
            med_block.append jQuery('<li>').html('Any')
        # set studios
        studio_block = ctx.find('.block.studios ul')
        if studio_block.length
          studio_block.html('')
          if ss.length
            _.each ss, (s) ->
              studio_block.append jQuery('<li>').html(s)
          else
            studio_block.append jQuery('<li>').html('Any')
        # os
        os_info = ctx.find('.block.os .os')
        if os_info.length
          oss = "Don't Care"
          if os
            oss = {'1':'Yes', '2': 'No'}[os]
          os_info.html(oss)

  initPaginator: () ->
    _that = this
    frm = jQuery(this.searchFormSelector)
    pages = jQuery('.paginator a')
    if pages.length
      _.each pages, (page) ->
        jQuery(page).bind 'click', (ev) ->
          # add current_page input
          newInput = jQuery('<input>', {'class':'current_page',type:'hidden', name:'p', value: this.data('page')})
          frm.append newInput
          _that._submitForm()
          false
    # setup per page hook
    jQuery('results_per_page').bind 'change', (ev) ->
      pp = frm.find('input[name=per_page]')
      if pp.length > 0
        pp = pp[1]
        pp.value = per_page.val()
        _that._submitForm(ev)

  _submitForm: (ev) ->
    _that = this
    frm = jQuery(_that.searchFormSelector)

    jQuery(@spinnerHook).spin(MAU.SpinnerOptions)
    if (frm.length)
      opts =
        url: '/search/fetch',
        success: (data, status, xhr) ->
          jQuery('#search_results').html(data)
          false
        error: (resp) ->
          false
        complete: () ->
          jQuery(_that.spinnerHook).spin(false)
          try
            _that.updateQueryParamsInView()
          catch err
            MAU.log err
            throw err
          _that.initPaginator()
          curpage = frm.find('input.current_page').first()
          curpage.remove() if curpage
          false
      ev.stopPropagation() if ev
      jQuery.ajax jQuery.extend(opts, data: frm.serialize())
      false


  toggleTarget: (event) ->
    # NOTE:  Within an event handler, 'this' always refers to the element they are registered on.
    t = this
    if !t.hasClassName('expanded')
      t.addClassName('expanded');
      jQuery(t).find('.sprite').replaceWith(sprite_plus_dom)
      jQuery(t).next('div').slideDown()
    else
      t.removeClassName('expanded')
      jQuery(t).find('.sprite').replaceWith(sprite_minus_dom)
      jQuery(t).next('div').slideUp()

jQuery ->
  new MAUSearch(['#medium_chooser','#studio_chooser'])
  
  jQuery('#search_link').bind('click', MAU.doSearch)
