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

  describe('findChildByTagName', function() {
    beforeEach(function() {
      var el = new Element('div');
      el.setAttribute('id','fixture');
      var ul = new Element('ul');
      var ii = 0;
      for(;ii < 4; ii++) {
        var li = new Element('li');
        li.setAttribute('class', 'whatever');
        li.innerHTML = ii;
        ul.insert(li);
      }
      el.insert(ul);
      if ($('fixture')) {
        $('fixture').remove();
      }
      $$('body')[0].insert(el);
    });
    it('finds the first child by tag name', function() {
      var ch = $("fixture").findChildByTagName('li');
      expect(ch.tagName).toEqual('LI');
      expect(ch.className).toEqual('whatever');
      expect(ch.innerHTML).toEqual('0');
    });
  });
});
        