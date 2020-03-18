import jQuery from "jquery";

export const isOverflowing = el =>
  el.scrollHeight > el.offsetHeight || el.scrollWidth > el.offsetWidth;

jQuery.fn.isOverflowing = function() {
  const el = jQuery(this)[0];
  return isOverflowing(el);
};
