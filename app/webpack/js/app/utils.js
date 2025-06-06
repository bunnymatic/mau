const debounce = function (func, threshold, execAsap) {
  var timeout;
  timeout = null;
  return function () {
    var args, delayed, obj;
    obj = this;
    args = arguments;
    delayed = function () {
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

export { debounce };
