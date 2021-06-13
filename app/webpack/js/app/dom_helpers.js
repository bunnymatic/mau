export const onEvent = (
  containerSelector,
  eventName,
  targetSelector,
  handler
) => {
  const container = document.querySelectorAll(containerSelector);
  let callback = handler;
  if (targetSelector) {
    callback = function (e) {
      // loop parent nodes from the target to the delegation node
      for (
        var target = e.target;
        target && target != this;
        target = target.parentNode
      ) {
        if (target.matches(targetSelector)) {
          handler.call(target, e);
          break;
        }
      }
    };
  }
  container.forEach((c) => {
    c.addEventListener(eventName, callback, Boolean(targetSelector));
  });
};

export const onReady = (fn) => {
  if (document.readyState != "loading") {
    fn();
  } else {
    document.addEventListener("DOMContentLoaded", fn);
  }
};
