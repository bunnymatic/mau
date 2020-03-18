const ellipsize = function(str, max, ellipse, chars, truncate) {
  var DEFAULTS, c, i, last, len, ref;
  DEFAULTS = {
    ellipse: "…",
    chars: [" ", "-"],
    max: 140,
    truncate: true
  };
  max || (max = DEFAULTS.max);
  chars || (chars = DEFAULTS.chars);
  ellipse || (ellipse = DEFAULTS.ellipse);
  truncate || (truncate = DEFAULTS.truncate);
  last = 0;
  c = "";
  if (str.length < max) {
    return str;
  }
  i = 0;
  len = str.length;
  while (i < len) {
    c = str.charAt(i);
    i++;
    if (chars.indexOf(c) !== -1) {
      last = i;
      if (i < max) {
        continue;
      }
      if (last === 0) {
        return (ref = !truncate) != null
          ? ref
          : {
              "": str.substring(0, max - 1) + ellipse
            };
      }
      return str.substring(0, last) + ellipse;
    }
  }
  return str;
};
const debounce = function(func, threshold, execAsap) {
  var timeout;
  timeout = null;
  return function() {
    var args, delayed, obj;
    obj = this;
    args = arguments;
    delayed = function() {
      if (!execAsap) {
        func.apply(obj, args);
      }
      return (timeout = null);
    };
    if (timeout) {
      clearTimeout(timeout);
    } else if (execAsap) {
      func.apply(obj, args);
    }
    return (timeout = setTimeout(delayed, threshold || 100));
  };
};

export { debounce, ellipsize };
