/*
for all elements with 'send-mau-a-note' class, popup a form to fill
out the appropriate info and fire off a note to mau emails

avoids 'mailto' links
*/
MAU = window.MAU || {};

MAU.PopupView = Class.create();

Object.extend(MAU.PopupView.prototype, {
  defaults: {
  },
  selector: null,
  _parent_class: function(selector) {
    if (selector) {
      return '.mau-popup-container';
    } else {
      return 'mau-popup-container';
    }
  },
  close: function(ev) {
    $$(this._parent_class(true)).each(function(el) {
      el.fade({duration:0.3, afterFinish: function() { el.remove(); }});
    });
    if (ev) {
      ev.stopPropagation();
    }
    return false;
  },
  insert: function(ev) {
    var event = ev || {};
    var _that = this;
    if ($$(this._parent_class(true)).length === 0 ) {
      var h = new Element('div', { "class": 'popup-header' }).update(this.options.title);
      var x = new Element('div', { "class": 'close-btn' }).update('x');
      h.insert(x);
      x.observe('click', function(ev) { _that.close(ev); });
      var c = new Element('div', { "class": 'popup-content' });
      $(c).insert( $(this.options.data_div).innerHTML );
      var m = new Element('div', { "class": 'popup-mailer' });
      m.observe('click', function(ev) { _that.close(ev); });
      $(m).insert(h).insert(c);
      var container = new Element('div', {"class":"mau-notes-subcontainer"});
      container.insert(m);
      var notes = new Element('div', { "class": _that._parent_class() }).insert(container);
      $$('body')[0].insert(notes);
    } 
  },
  initialize: function(selector, opts) {
    this.options = Object.extend({},this.defaults);
    this.options = Object.extend(this.options, opts);
    this.selector = selector;
    var _that = this;
    $$(this.selector).each(function(el) {
      $$(selector).each(function(root) {
        $(el).observe('click', function(ev) { _that.insert(ev); });
      });
    });
    if (window.location.hash == '#flaxinvite') {
      _that.insert();
    }
    
  }
});

Event.observe(window, 'load', function() {  
  var dummy = new MAU.PopupView("#news_text .read-more", { 
    title:"Invitation from Howard Flax", 
    data_div:"letter_from_flax"
  });
});
