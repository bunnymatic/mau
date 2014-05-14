describe 'jQuery.hideableRows', ->
  describe 'with default initialization', ->
    beforeEach ->
      loadFixtures('hideable_rows_table.html')
      jQuery('#hideable_row_table').hideableRows()
      
    it 'when you choose .two it hides rows with class .two', ->
      expect(jQuery('table .two.js-hidden-row').length).toEqual 0
      jQuery('#check_two').click()
      expect(jQuery('table .two.js-hidden-row').length).toEqual 2

  describe 'with custom row selector and input selectors', ->
    beforeEach ->
      loadFixtures('hideable_rows_div.html')
      jQuery('#hideable_row_divs').hideableRows({row: '.item', whatToHideSelectors: '.hiders input'})
      
    it 'when you choose .two it hides rows with class .two', ->
      expect(jQuery('.item.two.js-hidden-row').length).toEqual 0
      jQuery('#check_two').click()
      expect(jQuery('.item.two.js-hidden-row').length).toEqual 2

  describe 'with custom row selector and input selectors and multi-filter', ->
    beforeEach ->
      loadFixtures('hideable_multi_rows_div.html')
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
