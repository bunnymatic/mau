var Search = MAU.Search;

describe('Search', function() {
  describe('ShowHide', function() {
    beforeEach(function() {
      loadFixtures('search_showhide.html');
      Search.init();
    });
    it('initializes setting everything hidden', function() {
      var triggers = $$('#fixture .trigger');
      expect(triggers.length).toBeGreaterThan(0);
      _.each(triggers, function(t) {
        expect(t).toBeVisible();
      });
      var sections = $$('#fixture .expandable_section');
      expect(sections.length).toBeGreaterThan(0);
      _.each(sections, function(t) {
        expect(t).not.toBeVisible();
      });
    })
    it('clicking a header marks it expanded', function() {
      $('h1').simulate('click');
      expect($('h1')).toHaveClass('expanded');
    });
    it('clicking a header changes the arrow div', function() {
      $('h1').simulate('click');
      expect($('h1').select('.sprite.plus').length).toBeTruthy();
      expect($('h1').select('.sprite.minus').length).toBeFalsy();
    });
    it('clicking twice sets the arrow back and removes the expaneded class', function() {
      $('h2').simulate('click');
      $('h2').simulate('click');
      expect($('h1')).not.toHaveClass('expanded');
      expect($('h2').select('.sprite.minus').length).toBeTruthy();
      expect($('h2').select('.sprite.plus').length).toBeFalsy();
    });
  });
});
