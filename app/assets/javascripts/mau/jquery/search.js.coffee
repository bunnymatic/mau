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

# MAU.SearchSpinner = class MAUSearchSpinner
#   constructor: ->
#     @spinnerBG = '#spinnerbg'
#     @spinnerFG = '#spinnerfg'

#   create: ->
#     if jQuery(@spinnerBG)
#       jQuery(@spinnerBG).remove()
#     bg = new Element('div', {id:@spinnerBG, style:'display:none;'})
#     fg = new Element('div', {id:@spinnerFG, 'class':'search_spinner'})
#     bg.insert(fg)
#     c = jQuery('#container')[0]
#     c.insert(bg) if c
#     bg

#   show: ->
#     spinner = jQuery(@spinnerBG)
#     if (!spinner)
#       spinner = this.create()

#     #    spinner.clonePosition(jQuery('container'), {setLeft:false, setTop:false})
#     spinner.show();

#   hide: ->
#     spinner = jQuery(@spinnerBG)
#     if (spinner)
#       spinner.hide();


MAU.SearchPage = class MAUSearch

  sprite_minus_dom = '<div class="sprite minus" alt="hide" />'
  sprite_plus_dom = '<div class="sprite plus" alt="show" />'

  # initialize with checkbox container ids,
  # and the id of the box showing the current search params
  constructor: (chooserIds, currentSearch) ->
    @currentSearch = currentSearch
    @choosers = if !_.isArray(chooserIds) then [chooserIds] else chooserIds
    @checkboxSelector = '.cb_entry input[type=checkbox]'
    @searchFormSelector = 'form.power_search'
    @spinnerHook = '#spinner'
    _that = this
    jQuery ->
      _that.initExpandos()
      _that.initCBs()
      _that.initAnyLinks()
      _that.initFormSubmitOnChange()
      _that.initPaginator()


  # intialize the a.reset links
  initAnyLinks: ->
    _that = this
    _.each @choosers, (container) ->
      c = jQuery(container)
      _that.setAnyLink(c)
      lnk = c.find('.reset a').first()
      jQuery(lnk).bind('click', (ev) ->
        cbs = c.select _that.checkboxSelector
        _.each cbs, (el) ->
          el.checked = false
        _that.setAnyLink(c)
        ev.stopPropagation();
        _that._submitForm();
        return false
      ) if lnk

  # set a.reset links based on the checkbox content
  setAnyLink: (container) ->
    _that = this
    c = jQuery(container)
    if c
      cbs = c.select @checkboxSelector + ":checked"
      a = c.find('.reset a').first()
      if a
        if cbs.length
          a.show()
        else
          a.hide()

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
        _.each $c.select(_that.checkboxSelector), (item) ->
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
        _.each $c.select(_that.checkboxSelector), (item,idx) ->
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
    triggers = jQuery('.column .trigger')
    _.each triggers, (item) ->
      item.insert({ top: sprite_minus_dom })
      item.next().hide()
      jQuery(item).bind('click', _that.toggleTarget)
    expandeds = jQuery('.column .expanded')
    _.each expandeds, (item) ->
      item.insert({ top: sprite_plus_dom })
      item.addClassName('trigger')
      jQuery(item).bind('click', _that.toggleTarget)

    # if we have the search form, bind ajax to the submit
    #
    searchForm = jQuery(@searchFormSelector)
    if searchForm.length
      searchForm.bind 'submit', (ev) ->
        _that._submitForm(ev)
      false

  updateQueryParamsInView: ->
    _that = this
    # grab form params
    frm = jQuery(_that.searchFormSelector)
    if (frm.length)
      frm = Element.extend(frm[0])
      # get checked mediums
      ms = _.map frm.select('#medium_chooser input:checked'), (item) ->
        item.data('display')
      ss = _.map frm.select('#studio_chooser input:checked'), (item) ->
        item.data('display')
      os = null
      try
        os = frm.select('#os_artist')[0].selected().value
      catch err
        os = null
      kw = _.map frm.select('#keywords')[0].getValue().split(","), (s) ->
        s.trim()

      ctx = jQuery('.current_search')
      if ctx.length
        ctx = ctx[0]
        # set keywords
        kw_block = ctx.select('.block.keywords ul.keywords')[0]
        if kw_block
          kw_block.html('')
          _.each kw, (k,idx) ->
            s = k
            s = "AND " + s unless !idx
            li = new Element('li').update(s)
            kw_block.insert(li);
        # set mediums
        med_block = ctx.select('.block.mediums ul')[0]
        if med_block
          med_block.html('')
          if ms.length
            _.each ms, (m) ->
              med_block.insert new Element('li').update(m)
          else
            med_block.insert new Element('li').update('Any')
        # set studios
        studio_block = ctx.select('.block.studios ul')[0]
        if studio_block
          studio_block.html('')
          if ss.length
            _.each ss, (s) ->
              studio_block.insert new Element('li').update(s)
          else
            studio_block.insert new Element('li').update('Any')
        # os
        os_info = ctx.select('.block.os .os')[0]
        if os_info
          oss = "Don't Care"
          if os
            oss = {'1':'Yes', '2': 'No'}[os]
          os_info.html(oss)

  initPaginator: () ->
    _that = this
    frm = jQuery(this.searchFormSelector)[0]
    pages = jQuery('.paginator a')
    if pages.length
      _.each pages, (page) ->
        jQuery(page).bind 'click', (ev) ->
          # add current_page input
          frm.insert(new Element('input', {'class':'current_page',type:'hidden', name:'p', value: this.data('page')}))
          _that._submitForm()
          false
    # setup per page hook
    jQuery('results_per_page').bind 'change', (ev) ->
      pp = frm.find('input[name=per_page]').first()
      if pp
        pp.value = per_page.selected().value
        _that._submitForm(ev)

  _submitForm: (ev) ->
    _that = this
    frm = jQuery(_that.searchFormSelector)
    
    jQuery(@spinnerHook).spin(MAU.SpinnerOptions)
    if (frm.length)
      opts =
        url: '/search/fetch',
        success: (resp) ->
          jQuery('#search_results').html(resp)
          false
        failure: (resp) ->
          false
        complete: () ->
          jQuery(_that.spinnerHook).spin(false)
          try
            _that.updateQueryParamsInView()
          catch err
            MAU.log err
          _that.initPaginator()
          curpage = frm.find('input.current_page').first()
          curpage.remove() if curpage
          false
      ev.stopPropagation() if ev
      jQuery.ajax jQuery.extend(opts, data: frm.serialize())


  toggleTarget: (event) ->
    # NOTE:  Within an event handler, 'this' always refers to the element they are registered on.
    t = this
    if !t.hasClassName('expanded')
      t.addClassName('expanded');
      jQuery(t).find('.sprite').html(sprite_plus_dom)
      jQuery(t).next('div').slideDown()
    else
      t.removeClassName('expanded')
      jQuery(t).find('.sprite').html(sprite_minus_dom)
      jQuery(t).next('div').slideUp()


new MAUSearch(['#medium_chooser','#studio_chooser'])
