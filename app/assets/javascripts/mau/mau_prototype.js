MAU = window.MAU || {};

var MauPrototypeExtensions = {
  firstParentByTagName: function(elem, tagname){
    var el = $(elem);
    var entry = null;
    var parents = el.ancestors();
    var ii = 0;
    var n = parents.length;
    var tagMatch = tagname.toUpperCase();
    for (; ii < n; ++ii ) {
      var p = parents[ii];
      if (p && (p.tagName === tagMatch)) {
        return p;
      }
    }
    return null;
  },
  selectOne: function(elem, subSel) {
    var el = $(elem).select(subSel);
    return el.length ? el.first() : null;
  },
  hover: function(elem,infunc, outfunc) {
    if (!elem) { return; }
    var el = $(elem);
    el.observe('mouseover',infunc);
    el.observe('mouseout',outfunc);
  },
  html: function(elem, val) {
    if (!elem) {return;}
    elem.innerHTML = val;
  },
  // innerDimensions: function(elem) {
  //   if (!elem) {return;}
  //   var l = new Element.Layout(elem);
  //   return ({ width: l.get('width') + l.get('padding-left') + l.get('padding-right'),
  //             height: l.get('height') + l.get('padding-top') + l.get('padding-bottom')
  //           });
  // },
  outerDimensions: function(elem) {
    if (!elem) {return;}
    var l = new Element.Layout(elem);
    return ({ width: Math.max(l.get('width'), l.get('border-box-width'), l.get('margin-box-width')),
             height: Math.max(l.get('height'), l.get('border-box-height'), l.get('margin-box-height'))
            });
  },
  data: function(elem, key, val) {
    var DATA_REGEX = /data-(\w+)/;
    var ii = 0;
    var nattr = elem.attributes.length;
    if (key && val) {
      elem.setAttribute('data-' + key, val);
    }
    else {
      for (; ii < nattr; ++ii ) {
        var attr = elem.attributes[ii];
        if (attr && attr.name) {
          var m = attr.name.match(DATA_REGEX);
          if (m && m.length > 1) {
            var datakey = m[1];
            if (datakey === key) {
              return attr.value;
            }
          }
        }
      }
    }
  }
};

/** add aliases */
MauPrototypeExtensions.findChildByTagName = MauPrototypeExtensions.selectOne;


Element.addMethods(MauPrototypeExtensions);

if (!Function.prototype.debounce) {
  /**
      execAsap -> if true, do the action and suppress subsequent requests for threshold ms
                  if false, wait until threshold has passed, then execute
   **/
  Function.prototype.debounce = function (threshold, execAsap) {

    var func = this, timeout;

    return function debounced () {
      var obj = this, args = arguments;
      function delayed () {
        if (!execAsap) {
          func.apply(obj, args);
        }
        timeout = null;
      }

      if (timeout) {
        clearTimeout(timeout);
      }
      else if (execAsap) {
        func.apply(obj, args);
      }

      timeout = setTimeout(delayed, threshold || 100);
    };

  };
}


// protoHover
// a simple hover implementation for prototype.js
// Sasha Sklar and David Still
// from: https://code.google.com/p/protohover/downloads/detail?name=protohover.js&can=2&q=

(function() {
  // copied from jquery
  var withinElement = function(evt, el) {
    // Check if mouse(over|out) are still within the same parent element
    var parent = evt.relatedTarget;

    // Traverse up the tree
    while (parent && parent != el) {
      try {
	parent = parent.parentNode;
      } catch (error) {
	parent = el;
      }
    }
    // Return true if we actually just moused on to a sub-element
    return parent == el;
  };

  // Extend event with mouseEnter and mouseLeave
  Object.extend(Event, {
    mouseEnter: function(element, f, options) {
      element = $(element);

      // curry the delay into f
      var fc = (options && options.enterDelay)?(function(){window.setTimeout(f, options.enterDelay);}):(f);

      if (Prototype.Browser.IE) {
	element.observe('mouseenter', fc);
      } else {
	element.hovered = false;

	element.observe('mouseover', function(evt) {
	  // conditions to fire the mouseover
	  // mouseover is simple, the only change to default behavior is we don't want hover fireing multiple times on one element
	  if (!element.hovered) {
	    // set hovered to true
	    element.hovered = true;

	    // fire the mouseover function
	    fc(evt);
	  }
	});
      }
    },
    mouseLeave: function(element, f, options) {
      element = $(element);

      // curry the delay into f
      var fc = (options && options.leaveDelay)?(function(){window.setTimeout(f, options.leaveDelay);}):(f);

      if (Prototype.Browser.IE) {
	element.observe('mouseleave', fc);
      } else {
	element.observe('mouseout', function(evt) {
	  // get the element that fired the event
	  // use the old syntax to maintain compatibility w/ prototype 1.5x
	  var target = Event.element(evt);

	  // conditions to fire the mouseout
	  // if we leave the element we're observing
	  if (!withinElement(evt, element)) {
	    // fire the mouseover function
	    fc(evt);

	    // set hovered to false
	    element.hovered = false;
	  }
	});
      }
    }
  });

  // add method to Prototype extended element
  Element.addMethods({
    'hover': function(element, mouseEnterFunc, mouseLeaveFunc, options) {
      options = Object.extend({}, options) || {};
      Event.mouseEnter(element, mouseEnterFunc, options);
      Event.mouseLeave(element, mouseLeaveFunc, options);
    }
  });

  var Utils = {
    selected : function(elid) {
      var opts = $(elid).select('option');
      return opts.find(function(ele){return !!ele.selected;});
    }
  };

  Element.addMethods(Utils);

})();
