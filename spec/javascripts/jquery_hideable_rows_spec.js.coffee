describe 'jQuery.hideableRows', ->
  local_fixtures = {
    hideable_row_table: """
      <div id='hideable_row_table'>
        <fieldset class='hide-rows'>
         <input id='check_one' type='checkbox' value='one'>
         <input id='check_two' type='checkbox' value='two'>
         <input id='check_three' type='checkbox' value='three'>
        </fieldset>
        <table>
         <tbody>
          <tr class='one'></tr>
          <tr class='two'></tr>
          <tr class='three'></tr">
          <tr class='two'></tr>
         </tbody>
        </table>
      </div>""",
    hideable_row_rows: """
      <div id='hideable_row_divs'>
        <fieldset class='hiders'>
          <input id='check_one' type='checkbox' value='one'>
          <input id='check_two' type='checkbox' value='two'>
          <input id='check_three' type='checkbox' value='three'>
        </fieldset>
        <div class='items'>
          <div class='item one'></div>
          <div class='item two'></div>
          <div class='item three'></div>
          <div class='item two'></div>
        </div>
      </div>""",
    multi_hideable_rows: """
      <div id='hideable_multi_row_divs'>
        <fieldset class='hiders'>
          <input id='check_published' type='checkbox' value='published'>
          <input id='check_past' type='checkbox' value='past'>
          <input id='check_future' type='checkbox' value='future'>
        </fieldset>
        <div class='items'>
          <div class='item published past'></div>
          <div class='item published future'></div>
          <div class='item published past'></div>
          <div class='item unpublished past'></div>
          <div class='item unpublished future'></div>
        </div>
      </div>
    """
  }



  describe 'with default initialization', ->
    beforeEach ->
      fixture.set(local_fixtures.hideable_row_table)
      jQuery('#hideable_row_table').hideableRows()

    it 'when you choose .two it hides rows with class .two', ->
      expect(jQuery('table .two.js-hidden-row').length).toEqual 0
      jQuery('#check_two').click()
      expect(jQuery('table .two.js-hidden-row').length).toEqual 2

  describe 'with custom row selector and input selectors', ->
    beforeEach ->
      fixture.set(local_fixtures.hideable_row_rows)
      jQuery('#hideable_row_divs').hideableRows({row: '.item', whatToHideSelectors: '.hiders input'})

    it 'when you choose .two it hides rows with class .two', ->
      expect(jQuery('.item.two.js-hidden-row').length).toEqual 0
      jQuery('#check_two').click()
      expect(jQuery('.item.two.js-hidden-row').length).toEqual 2

  describe 'with custom row selector and input selectors and multi-filter', ->
    beforeEach ->
      fixture.set(local_fixtures.multi_hideable_rows)
      jQuery('#hideable_multi_row_divs').hideableRows({row: '.item', whatToHideSelectors: '.hiders input', multiFilter: true})

    it 'when you choose past it hides the past elements', ->
      expect(jQuery('.js-hidden-row').length).toEqual 0
      jQuery('#check_past').click()
      expect(jQuery('.item.past').length).toEqual 3
      expect(jQuery('.item.past.js-hidden-row')).toEqual jQuery('.item.past')

    it 'when you choose published and future it hides all published and/or future elements', ->
      expect(jQuery('.js-hidden-row').length).toEqual 0
      jQuery('#check_past').click()
      jQuery('#check_published').click()
      expect(jQuery('.item.past.js-hidden-row')).toEqual jQuery('.item.past')
      expect(jQuery('.item.published.js-hidden-row')).toEqual jQuery('.item.published')

    it 'when you choose published and future, then unclick future, it does not filter future', ->
      expect(jQuery('.js-hidden-row').length).toEqual 0
      jQuery('#check_future').click()
      jQuery('#check_published').click()
      expect(jQuery('.item.future.js-hidden-row')).toEqual jQuery('.item.future')
      expect(jQuery('.item.published.js-hidden-row')).toEqual jQuery('.item.published')
      jQuery('#check_future').click()
      expect(jQuery('.item.published.js-hidden-row')).toEqual jQuery('.item.published')
      expect(jQuery('.item.future.js-hidden-row').length).toEqual 1 # still hides the published future
