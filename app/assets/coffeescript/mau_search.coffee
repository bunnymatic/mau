MAU = window.MAU = window.MAU || {}
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
    _that = this
    Event.observe window, 'load', ->
      _that.initExpandos()
      _that.initCBs()
      _that.initAnyLinks()


  # intialize the a.reset links
  initAnyLinks: ->
    _that = this
    _.each @choosers, (container) ->
      c = $(container)
      lnk = c.selectOne('a.reset') if c
      Event.observe(lnk, 'click', (ev) ->
        cbs = c.select _that.checkboxSelector
        _.each cbs, (el) ->
          el.checked = false
        _that.setAnyLink(c)
        ev.stop();
        return false
      ) if lnk

  # set a.reset links based on the checkbox content
  setAnyLink: (container) ->
    _that = this
    c = $(container)
    if c
      cbs = c.select @checkboxSelector
      a = c.selectOne('a.reset')
      if a && a.length
        if _.uniq( _.map(cbs, (c) ->
           c.checked
        )).length > 1
          a.show()
        else
          a.hide()

  initCBs: ->
    _that = this

    # if the first is checked, uncheck all others
    # if none are checked, check the first
    # if the first is checked and we check another, uncheck the first
    # click happens before the 'check' is registered on the checkbox
    # change happens after
    _.each @choosers, (c) ->
      $c = $(c)
      if $c
        cbs = $c.select(_that.checkboxSelector) || []
        _.each cbs, (item,idx) ->
          Event.observe item, 'change', (ev) ->
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
    triggers = $$('.column .trigger')
    _.each triggers, (item) ->
      item.insert({ top: sprite_minus_dom })
      item.next().hide()
      item.observe('click', _that.toggleTarget)
    expandeds = $$('.column .expanded')
    _.each expandeds, (item) ->
      item.insert({ top: sprite_plus_dom })
      item.addClassName('trigger')
      item.observe('click', _that.toggleTarget)

    # if we have the search form, bind ajax to the submit
    #
    searchForm = $$(@searchFormSelector)
    if searchForm.length
      frm = searchForm[0]
      Event.observe frm,'submit', _that._submitForm
      return false;

  updateQueryParamsInView: ->
    _that = this
    # grab form params



  _submitForm: (ev) ->
    _that = this
    searchForm = $$(@searchFormSelector)
    if (searchForm.length)
      searchForm = searchForm[0]
      opts =
        onSuccess: (resp) ->
          $('search_results').innerHTML = resp.responseText
          false
        onFailure: (resp) ->
          false
        onComplete: (resp) ->
          _that.updateQueryParamsInView();
          false
      ev.stop()
      searchForm.request(opts)
    false


  toggleTarget: (event) ->
    # NOTE:  Within an event handler, 'this' always refers to the element they are registered on.
    _that = this
    t = event.currentTarget || event.target
    if !t.hasClassName('expanded')
      t.addClassName('expanded');
      t.down('div').replace( sprite_plus_dom )
      t.next().blindDown(MAU.BLIND_OPTS.down)
    else
      t.removeClassName('expanded')
      t.down('div').replace( sprite_minus_dom )
      t.next().slideUp(MAU.BLIND_OPTS.up)
    return false;


new MAUSearch(['medium_chooser','studio_chooser'])
