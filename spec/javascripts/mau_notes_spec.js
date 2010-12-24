require("spec_helper.js");
require("../../public/javascripts/prototype/1.7/prototype.min.js", { onload: function() {
  require("../../public/javascripts/mau.js");
  require("../../public/javascripts/mau_notes.js");
}});

Screw.Unit(function(){
  before(function() {
    $$('.inquiry').each(function(el) { el.remove(); } );
    $$('.email_list').each(function(el) { el.remove(); });
  });
  describe("mau notes", function() {
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

  describe("insert", function() {
    it ("adds the inquiry elements", function() {
      var sxn = 'inquiry';
      var m = new MAU.NotesMailer("#fixture", sxn);
      m.insert(); // click bound
      expect($('fixture').select('.' + sxn + ' .popup-mailer').length).to(equal, 1);
    });

    describe("email_list", function() {
      var sxn = 'email_list';
      before(function() {
        var m = new MAU.NotesMailer("#fixture", sxn);
        m.insert(); // click bound
      });
      it ("adds the popup-mailer container", function() {
        expect($('fixture').select('.' + sxn + ' .popup-mailer').length).to(equal, 1);
      });
      it ("adds email input", function() {
        expect($$('input#email').length).to(equal, 1);
      });
    });
    describe("inquiry", function() {
      var sxn = 'inquiry';
      before(function() {
        var m = new MAU.NotesMailer("#fixture", sxn);
        m.insert(); // click bound
      });
      it ("adds the popup-mailer container", function() {
        expect($('fixture').select('.' + sxn + ' .popup-mailer').length).to(equal, 1);
      });
    });

  });
});
