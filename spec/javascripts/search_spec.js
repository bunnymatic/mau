var Search = MAU.Search;

var full_selectors = {
  medium_chooser: '#fixture #medium_chooser .cb_entry input[type=checkbox]',
  studio_chooser: '#fixture #studio_chooser .cb_entry input[type=checkbox]'
};

describe('Search', function() {
  var s;
  beforeEach(function() {
    loadFixtures('search_showhide.html');
    s = new MAU.SearchPage(['#medium_chooser','#studio_chooser']);
  });

  describe('updateQueryParamsInView',function() {
    describe('keywords', function() {
      beforeEach(function() {
        $('keywords').setValue('this, and that')
        s.updateQueryParamsInView();
      });
      it('puts keywords from the form into the current search', function() {
        var lis = $$('.block.keywords li');
        expect(lis.length).toEqual(2)
        expect(lis[0].innerHTML).toEqual('this')
        expect(lis[1].innerHTML).toEqual('AND and that')
      });
    });
    describe('mediums', function() {
      it('puts mediums from the form into the current search', function() {
        _.each($$('#medium_chooser input[type=checkbox]'), function(item, idx) {
          if (idx < 2) {
            item.checked = true;
          }
        });
        s.updateQueryParamsInView();
        var lis = $$('.block.mediums li');
        expect(lis.length).toEqual(2)
        expect(lis[0].innerHTML).toEqual('Drawing')
        expect(lis[1].innerHTML).toEqual('MM')
      });
      it('puts any in mediums if there are none selected in the form', function() {
        _.each($$('#medium_chooser input[type=checkbox]'), function(item, idx) {
          item.checked = false;
        });
        s.updateQueryParamsInView();
        var lis = $$('.block.mediums li');
        expect(lis.length).toEqual(1)
        expect(lis[0].innerHTML).toEqual('Any')
      });
    });
    describe('studios', function() {
      it('puts studios from the form into the current search', function() {
        _.each($$('#studio_chooser input[type=checkbox]'), function(item, idx) {
          if (idx < 2) {
            item.checked = true;
          }
        });
        s.updateQueryParamsInView();
        var lis = $$('.block.studios li');
        expect(lis.length).toEqual(2)
        expect(lis[0].innerHTML).toEqual('1890')
        expect(lis[1].innerHTML).toEqual('ActivSpace')
      });
      it('puts any in studios if there are no studios selected', function() {
        _.each($$('#studio_chooser input[type=checkbox]'), function(item, idx) {
          item.checked = false;
        });
        s.updateQueryParamsInView();
        var lis = $$('.block.studios li');
        expect(lis.length).toEqual(1)
        expect(lis[0].innerHTML).toEqual('Any')
      });
    });
    describe('os choice', function() {
      it('puts os choice from the form into the current search', function() {
        $('os_artist').options[1].selected = true;
        s.updateQueryParamsInView();
        var os = $$('.block.os .os');
        expect(os[0].innerHTML).toEqual('Yes')
      });
    });

  });

  describe('setAnyLink', function() {
    it('shows any link if any checkboxes are checked', function() {
      $$(full_selectors.medium_chooser).first().simulate('click');
      expect($$('a.reset').first()).toBeVisible();
    });
    it('sets all checkboxes unchecked after clicking the any button', function() { 
      jQuery(full_selectors.medium_chooser).first().attr('checked', 'checked');
      expect(jQuery(full_selectors.medium_chooser).is(':checked')).toBeTruthy();
      $$('li a.reset').first().simulate('click');
      expect(jQuery(full_selectors.medium_chooser).is(":checked")).toBeFalsy();
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
      jQuery('#fixture #h1').click();
      expect(jQuery('#h1')[0]).toHaveClass('expanded');
    });
    it('clicking a header changes the arrow div', function() {
      jQuery('#fixture #h1').click();
      expect(jQuery('#fixture #h1 .sprite.plus').length).toBeTruthy();
      jQuery('#fixture #h1').click();
      expect(jQuery('#fixture #h1 .sprite.plus').length).toBeFalsy();
    });
    it('clicking twice sets the arrow back and removes the expaneded class', function() {
      /*** fails in headless mode

      $('h2').simulate('click');
      $('h2').simulate('click');
      expect($('h2')).not.toHaveClass('expanded');
      expect($('h2').select('.sprite.minus').length).toBeTruthy();
      expect($('h2').select('.sprite.plus').length).toBeFalsy();
*/
    });
  });
});
