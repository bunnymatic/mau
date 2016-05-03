describe('Flash', function() {
  beforeEach(function() {
    fixtures.set '<div id="fixture"><div class="container"></div></div>'
  });

  describe('show', function() {
    beforeEach(function() {
      var jsf = jQuery('#jsFlash');
      if (jsf) { jsf.remove(); }
    });
    it ('draws an error div', function() {
      var f = new MAU.Flash()
      f.show({'error': 'this is the new error', 'notice':'this is the notice'});
      expect(jQuery('#jsFlash .flash__error').html()).toEqual('this is the new error');
    });

    it ('draws an error div in the container', function() {
      var f = new MAU.Flash()
      f.show({'error': 'this is the new error', 'notice':'this is the notice'}, '#fixture .container');
      expect(jQuery('#fixture .flash__error').html()).toEqual('this is the new error');
    });

  });
});
