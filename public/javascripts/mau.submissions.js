(function() {
MAU = window['MAU'] || {};

Submissions = MAU.S = MAU.S || {}

var S = Submissions;

var countChecked = function() {
  var numChecked = 0;
  $$('.flax-chooser input.checker').each(function(el) {
    if(el.checked) { numChecked ++ ; }
  });
  return numChecked;
};

var validateSubmission = function(ev) {
  var nchecked = countChecked();
  if (nchecked > 3) {
    alert("You cannot choose more than 3 pieces.  Please adjust your selection before proceeding");
    ev.target.checked = false;
    ev.stop();
    return false;
  }
  return true;
};

var validateOnSubmit = function(ev) {
  if (!validateSubmission(ev)) {
    return false;
  }
  var os_status = $$('input[name=springos201104]');
  if (os_status && os_status.length) {
    if (!os_status[0].checked) {
      alert("To enter this show, you must be participating in Open Studios on April 16/17.  If you are planning to participate, simply check the \"I'm participating...\" checkbox and you can submit your work.");
      ev.stop();
      return false;
    }
  }
  return true;
};

Object.extend(S, {
  init: function() {
    $$('input[type=checkbox]').each(function(el){
      el.observe('click', validateSubmission );
    });
    Event.observe('submitPics', 'submit', function(ev) {
      if (!validateOnSubmit(ev)) {
        ev.stopPropagation();
        return false;
      }
    });
  }
});

Event.observe(window,'load', S.init);
})();