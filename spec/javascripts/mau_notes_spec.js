jQuery.noConflict();

require("spec_helper.js");
require("../../public/javascripts/prototype/1.7/prototype.min.js", { onload: function() {
  require("../../public/javascripts/mau.js");
  require("../../public/javascripts/mau_cookies.js");
  require("../../public/javascripts/mau_notes.js");
}});

Screw.Unit(function(){
  before(function() {
    $$('.inquiry').each(function(el) { el.remove(); } );
    $$('.email_list').each(function(el) { el.remove(); });
  });
  describe("mau notes", function() {
    it ("sets up a close button with click handler", function() {
      var sxn = 'inquiry';
      var m = new MAU.NotesMailer("#fixture", { note_class: sxn });
      var clickEvents = get_click_events('#fixture .close-btn');
      expect(clickEvents.length).to(equal,1);
    });
    it ("sets up inquiry inputs", function() {
      var sxn = 'inquiry';
      var m = new MAU.NotesMailer("#fixture .general", { note_class: sxn });
      var clickEvents = get_click_events("#fixture .general");
      expect(clickEvents.length).to(equal,1);
    });
    it ("fails to setup 'blah' inputs - not a valid note type", function() {
      var sxn = 'blah';
      var m = new MAU.NotesMailer("#fixture .blah", { note_class: sxn });
      var clickEvents = get_click_events("#fixture .blah");
      expect(clickEvents.length).to(equal,0);
    });
    it ("sets up email notes", function() {
      var sxn = 'email_list';
      var m = new MAU.NotesMailer("#fixture .emailus", { note_class: sxn });
      var clickEvents = get_click_events("#fixture .emailus");
      expect(clickEvents.length).to(equal,1);
    });
  });

  describe('submit', function() {
    var sxn = 'email_list';
    var m;
    before(function() {
      m = new MAU.NotesMailer("#fixture", { note_class: sxn, url: 'myurl'} );
    });
    it ("has handler", function() {
      var events = get_events('#fixture .' + sxn + ' form', 'submit');
      expect(events.length).to(equal, 1);
    });
  });
  describe("close (on click close)", function() {
    var sxn = 'email_list';
    before(function() {
      var m = new MAU.NotesMailer("#fixture", { note_class: sxn, url: 'myurl'} );
      var mymock = mock(function() {});
      stub(mymock, 'stopPropagation').and_return(true);
      m.close(mymock);
    });
    it ("form gets hidden", function() {
      expect($$('.' + sxn)[0].visible()).to(equal, false);
    });

  });
  describe("insert (on click)", function() {
    describe("email_list", function() {
      var sxn = 'email_list';
      before(function() {
        var m = new MAU.NotesMailer("#fixture", { note_class: sxn, url: 'myurl'} );
      });
      it ("adds the popup-mailer container", function() {
        expect($('fixture').select('.' + sxn + ' .popup-mailer').length).to(equal, 1);
      });
      it ("adds 2 email inputs", function() {
        expect($$('.' + sxn + ' .popup-mailer .popup-content form input#email').length).to(equal, 1);
        expect($$('.' + sxn + ' .popup-mailer .popup-content form input#email_confirm').length).to(equal, 1);
      });
      it ('has a submit button', function() {
        expect($$('.' + sxn + ' .popup-mailer .popup-content form input[type=submit]').length).to(equal, 1);
      });
      it ('points to the right url', function() {
        expect($$('.' + sxn + ' .popup-mailer .popup-content form[action=myurl]').length).to(equal,1);
      });
      it ('fills in the title', function() {
        expect($$('.popup-mailer .popup-header')[0].innerHTML.match('Join our mailing list')[0]).to(equal, 'Join our mailing list');      
      });
      it ('has a close button', function() {
        expect($$('.popup-mailer .popup-header .close-btn').length).to(equal,1);
      });
    });
    describe("double insert", function() {
      var sxn = 'email_list';
      before(function() {
        var m = new MAU.NotesMailer("#fixture", { note_class: sxn, url: 'myurl'} );
        m.insert(); 
      });
      it ("doesn't add 2 of everything", function() {
        expect($('fixture').select('.' + sxn + ' .popup-mailer').length).to(equal, 1);
        expect($$('.' + sxn + ' .popup-mailer .popup-content form input#email').length).to(equal, 1);
        expect($$('.' + sxn + ' .popup-mailer .popup-content form input#email_confirm').length).to(equal, 1);
        expect($$('.popup-mailer .popup-header .close-btn').length).to(equal,1);
      });
    });

    describe("inquiry", function() {
      var sxn = 'inquiry';
      before(function() {
        var m = new MAU.NotesMailer("#fixture", { note_class: sxn, url: 'theurl'} );
      });
      it ("adds the popup-mailer container", function() {
        expect($('fixture').select('.' + sxn + ' .popup-mailer').length).to(equal, 1);
      });
      it ('points to the right url', function() {
        expect($$('.' + sxn + ' .popup-mailer form[action=theurl]').length).to(equal,1);
      });
      it ('fills in the title', function() {
        expect($$('.popup-mailer .popup-header')[0].innerHTML.match('General Inquiry')[0]).to(equal, 'General Inquiry');      });
      it ('has a close button', function() {
        expect($$('.popup-mailer .popup-header .close-btn').length).to(equal,1);
      });
    });
    describe("both forms on same page", function() {
      var s1 = 'inquiry';
      var s2 = 'email_list';
      before(function() {
        var m1 = new MAU.NotesMailer("#fixture .general", { note_class: s1, url: 'myurl'} );
        var m2 = new MAU.NotesMailer("#fixture .emailus", { note_class: s2, url: 'myurl'} );
        console.log(m1);
        console.log(m2);
      });
      it("shows general form", function() {
        expect($$('#fixture .general .popup-mailer').length).to(equal,1);      
      });
      it("shows email form", function() {
        expect($$('#fixture .emailus .popup-mailer').length).to(equal,1);
      });
    });
  });
});
