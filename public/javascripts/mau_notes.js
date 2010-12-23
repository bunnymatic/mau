/*
for all elements with 'send-mau-a-note' class, popup a form to fill
out the appropriate info and fire off a note to mau emails

avoids 'mailto' links
*/

MAU = window['MAU'] || {};

MAU.NotesMailer = Class.create();

Object.extend(MAU.NotesMailer.prototype, {
  initialize: function(selector) {
    this.elements = selector;
    $$(selector).each(function(item) {
      item.observe('click', function(event) {
        console.log(event.target);
      });
    });
  }
});

Event.observe(window,'load', function() {
  var nm = new MAU.NotesMailer('.send-mau-a-note');
});
