var Search = MAU.Search;

var full_selectors = {
  medium_chooser: '#fixture #medium_chooser .cb_entry input[type=checkbox]',
  studio_chooser: '#fixture #studio_chooser .cb_entry input[type=checkbox]'
};

describe('Search', function() {
  var s;
  beforeEach(function() {
    loadFixtures('search_showhide.html');
    s = new MAU.SearchPage(['medium_chooser','studio_chooser']);
    s.initExpandos()
    s.initCBs()
    s.initAnyLinks()
  });
  
  describe('  updateQueryParamsInView',function() {
    it('works', function() {
      expect(false).toBeTruthy();
    });
  });
  
  describe('setAnyLink', function() {
    it('shows any link if any checkboxes are checked', function() {
      $$(full_selectors.medium_chooser).first().simulate('click');
      expect($$('a.reset').first()).toBeVisible();
    });
    it('sets all checkboxes unchecked after clicking the any button', function() {
      $$(full_selectors.medium_chooser).first().simulate('click');
      $$('a.reset').first().simulate('click')
      expect($$(full_selectors.medium_chooser).any(function(cb) { return cb.checked; })).toBeFalsy();
    });

  });

  
  describe('ShowHide', function() {
    it('initializes setting everything hidden', function() {
      var triggers = $$('#fixture .trigger');
      expect(triggers.length).toBeGreaterThan(0);
      _.each(triggers, function(t) {
        expect(t).toBeVisible();
      });
      var sections = $$('#fixture .expandable');
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
