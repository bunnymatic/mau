require("spec_helper.js");
require("../../public/javascripts/prototype/1.7/prototype.min.js", { onload: function() {
  require("../../public/javascripts/mau.js");
  require("../../public/javascripts/mau_notes.js");
}});

Screw.Unit(function(){
  describe("mau notes", function() {
    before(function() {
    });
    it ("sets up inquiry inputs", function() {
      var sxn = 'inquiry';
      var m = new MAU.NotesMailer("#fixture", sxn);
      var clickEvents = []
      try {
        clickEvents = $("fixture").select("." + sxn)[0].getStorage().get('prototype_event_registry').get('click');
      } 
      catch(e) {}
      expect(clickEvents.length).to(equal,1);
    });
    it ("fails to setup 'blah' inputs - not a valid note type", function() {
      var sxn = 'blah';
      var m = new MAU.NotesMailer("#fixture", sxn);
      var clickEvents = []
      try {
        clickEvents = $("fixture").select("." + sxn)[0].getStorage().get('prototype_event_registry').get('click');
      }
      catch(e) {}
      expect(clickEvents.length).to(equal,0);
    });
    it ("sets up email notes", function() {
      var sxn = 'email_list';
      var m = new MAU.NotesMailer("#fixture", sxn);
      var clickEvents ;
      try {
        clickEvents = $("fixture").select("." + sxn)[0].getStorage().get('prototype_event_registry').get('click');
      }
      catch(e){}
      expect(clickEvents.length).to(equal,1);
    });
  });
});
