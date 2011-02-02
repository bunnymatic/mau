MAU = window['MAU'] || {};

Submissions = MAU.S = MAU.S || {}

var S = Submissions;

Object.extend(S, {
  countChecked: function() {
    var numChecked = 0;
    $$('.flax-chooser input.checker').each(function(el) {
      if(el.checked) { numChecked ++ ; }
    });
    return numChecked;
  },
  validateSubmission: function(ev) {
    var nchecked = S.countChecked();
    if (nchecked > 3) {
      alert("You cannot choose more than 3 pieces.  Please adjust your selection before proceeding");
      ev.target.checked = false;
      return false;
    }
    ev.stopPropagation();
    return true;
  },
  init: function() {
    $$('input[type=checkbox]').each(function(el){
      el.observe('click', S.validateSubmission );
    });
    $$('form')[0].observe('submit', function() {
      if (S.validateSubmission()) {
        $(this).submit();
      }
      else {
        return false; 
      }
    });
  }
});

Event.observe(window,'load', S.init);
