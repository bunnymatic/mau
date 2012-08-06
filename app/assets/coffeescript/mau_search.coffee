MAU = window.MAU = window.MAU || {}
MAU.SearchPage = class MAUSearch

  sprite_minus_dom = '<div class="sprite minus" alt="hide" />'
  sprite_plus_dom = '<div class="sprite plus" alt="show" />'

  constructor: ->

  init: ->
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
    triggers = $$('.column .trigger')
    _.each triggers, (item) ->
      item.insert({ top: sprite_minus_dom })
      item.next().hide()
      item.observe('click', MAUSearch.toggleTarget)
    expandeds = $$('.column .expanded')
    _.each expandeds, (item) ->
      item.insert({ top: sprite_plus_dom })
      item.addClassName('trigger')
      item.observe('click', MAUSearch.toggleTarget)

    # if we have the search form, bind ajax to the submit
    #
    searchForm =  $$('form.power_search')
    if searchForm.length
      frm = searchForm[0]
      Event.observe frm,'submit', (ev) ->
        opts = onSuccess: (resp) ->
          $('search_results').innerHTML = resp.responseText
          false
        ev.stop()
        frm.request(opts)
        false

  @toggleTarget: (event) ->
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


s = new MAUSearch()

Event.observe(window, 'load', s.init)
