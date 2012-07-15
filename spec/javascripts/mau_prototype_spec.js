describe("MAU Prototype Extensions", function() {
  describe('data', function() {
    it('properly returns the data attributes', function() {
      var el = new Element('div', {'data-mydata': 'MyData'});
      expect(el.data('mydata')).toEqual('MyData');
    });
    it('sets data attributes',function() {
      var div = new Element('div');
      div.data('whatever', 'yo');
      expect(div.getAttribute('data-whatever')).toEqual('yo');
    });
    it('overwrites existing attribute of the same value', function() {
      var el = new Element('div', {'data-mydata': 'MyData'});
      el.data('mydata', 'bs');
      expect(el.data('mydata')).toEqual('bs');
      expect(el.getAttribute('data-mydata')).toEqual('bs');
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
        