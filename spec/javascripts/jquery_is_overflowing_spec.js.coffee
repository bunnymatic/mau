describe 'jQuery.isOverflowing', ->
  describe 'with default initialization', ->
    beforeEach ->
      loadFixtures('is_overflowing.html')

    it 'is not overflowing with a small amount of content', ->
      expect(jQuery('#fixture .overflow').isOverflowing()).toBeFalsy()

    it 'is overflowing with lots of content', ->
      jQuery('#fixture .overflow').html("this should be <br/> enough content to make that div overflow<br/>")
      expect(jQuery('#fixture .overflow').isOverflowing()).toBeTruthy();
