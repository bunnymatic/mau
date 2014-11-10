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
        jQuery('#keywords').val('this, and that')
        s.updateQueryParamsInView();
      });
      it('puts keywords from the form into the current search', function() {
        var lis = jQuery('.block.keywords li');
        expect(lis.length).toEqual(2)
        expect(lis[0].innerHTML).toEqual('this')
        expect(lis[1].innerHTML).toEqual('AND and that')
      });
    });
    describe('mediums', function() {
      it('puts mediums from the form into the current search', function() {
        jQuery('#medium_chooser input[type=checkbox]').each(function(idx, item) {
          if (idx < 2) {
            item.checked = true;
          }
        });
        s.updateQueryParamsInView();
        var lis = jQuery('.block.mediums li');
        expect(lis.length).toEqual(2)
        expect(lis[0].innerHTML).toEqual('Drawing')
        expect(lis[1].innerHTML).toEqual('MM')
      });
      it('puts any in mediums if there are none selected in the form', function() {
        _.each(jQuery('#medium_chooser input[type=checkbox]'), function(item, idx) {
          item.checked = false;
        });
        s.updateQueryParamsInView();
        var lis = jQuery('.block.mediums li');
        expect(lis.length).toEqual(1)
        expect(lis[0].innerHTML).toEqual('Any')
      });
    });
    describe('studios', function() {
      it('puts studios from the form into the current search', function() {
        _.each(jQuery('#studio_chooser input[type=checkbox]'), function(item, idx) {
          if (idx < 2) {
            item.checked = true;
          }
        });
        s.updateQueryParamsInView();
        var lis = jQuery('.block.studios li');
        expect(lis.length).toEqual(2)
        expect(lis[0].innerHTML).toEqual('1890')
        expect(lis[1].innerHTML).toEqual('ActivSpace')
      });
      it('puts any in studios if there are no studios selected', function() {
        _.each(jQuery('#studio_chooser input[type=checkbox]'), function(item, idx) {
          item.checked = false;
        });
        s.updateQueryParamsInView();
        var lis = jQuery('.block.studios li');
        expect(lis.length).toEqual(1)
        expect(lis[0].innerHTML).toEqual('Any')
      });
    });
    describe('os choice', function() {
      it('puts os choice from the form into the current search', function() {
        jQuery('#os_artist').val(1);
        s.updateQueryParamsInView();
        var os = jQuery('.block.os .os');
        expect(os[0].innerHTML).toEqual('Yes')
      });
    });

  });

  describe('setAnyLink', function() {
    it('shows any link if any checkboxes are checked', function() {
      jQuery('.expandable').show()
      jQuery(full_selectors.medium_chooser).first().trigger('click');

      expect(jQuery('a.reset').first()).toBeVisible();
    });
    it('sets all checkboxes unchecked after clicking the any button', function() {
      jQuery('#medium_chooser .sprite').click();
      jQuery(full_selectors.medium_chooser).first().attr('checked', 'checked');
      expect(jQuery(full_selectors.medium_chooser).is(':checked')).toBeTruthy();
      jQuery('li a.reset').first().trigger('click');
      expect(jQuery(full_selectors.medium_chooser).is(":checked")).toBeFalsy();
    });

  });


  describe('ShowHide', function() {
    it('initializes setting everything hidden', function() {
      var triggers = jQuery('#fixture .trigger');
      expect(triggers.length).toBeGreaterThan(0);
      _.each(triggers, function(t) {
        expect(t).toBeVisible();
      });
      var sections = jQuery('#fixture .expandable');
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
      expect(jQuery('#fixture #h1 .sprite.minus').length).toBeTruthy();
      jQuery('#fixture #h1').click();
      expect(jQuery('#fixture #h1 .sprite.minus').length).toBeFalsy();
    });
  });
});
