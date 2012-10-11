describe('Flash', function() {
  beforeEach(function() {
    loadFixtures('jsflash.html');
  });
  describe('construct', function() {
    var div = null;
    beforeEach(function() {
      div = MAU.Flash.construct({'error': 'this is the error', 'notice':'this is the notice'});
    });
    it ('draws an error div', function() {
      expect(div.selectOne('.error-msg').innerHTML).toEqual('this is the error');
    });
    it ('draws an notice div', function() {
      expect(div.selectOne('.notice').innerHTML).toEqual('this is the notice');
    });
  });
  describe('show', function() {
    beforeEach(function() {
      var jsf = $('jsFlash');
      if (jsf) { jsf.remove(); }
    });
    it ('draws an error div', function() {
      MAU.Flash.show({'error': 'this is the new error', 'notice':'this is the notice'});
      expect($('jsFlash').selectOne('.error-msg').innerHTML).toEqual('this is the new error');
    });

    it ('draws an error div in the container', function() {
      MAU.Flash.show({'error': 'this is the new error', 'notice':'this is the notice'}, '#fixture .container');
      expect($$('#fixture .error-msg')[0].innerHTML).toEqual('this is the new error');
    });

  });
});
