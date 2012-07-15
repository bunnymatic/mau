describe("MAU Prototype Extensions", function() {
  describe('data', function() {
    it('properly returns the data attributes', function() {
      var el = new Element('div', {'data-mydata': 'MyData'});
      expect(el.data('mydata')).toEqual('MyData');
    });
  });
  describe('html', function() {
    it('sets the inner html of the dom element', function() {
      var el = new Element('div');
      el.html('this is the html');
      expect(el.innerHTML).toEqual('this is the html');
    });
  });
});
        