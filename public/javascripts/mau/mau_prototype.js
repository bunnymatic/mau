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
MauPrototypeExtensions.findChildByTagName = MauPrototypeExtensions.selectOne


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
      };
      
      if (timeout) {
        clearTimeout(timeout);
      }
      else if (execAsap) {
        func.apply(obj, args);
      }
      
      timeout = setTimeout(delayed, threshold || 100); 
    };
    
  }
}

if (!String.prototype.trim) {
  String.prototype.trim = function() { return this.replace(/^\s\s*/, '').replace(/\s\s*$/, ''); };
}