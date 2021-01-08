const hasProp = {}.hasOwnProperty;

const Email = (function () {
  function Email(model) {
    var key, value;
    for (key in model) {
      if (!hasProp.call(model, key)) {
        continue;
      }
      value = model[key];
      this[key] = value;
    }
  }

  Email.prototype.formatted = function () {
    return this.name + " <" + this.email + ">";
  };

  return Email;
})();

angular.module("mau.models").factory("Email", () => Email);
