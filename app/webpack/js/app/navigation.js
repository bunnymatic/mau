import jQuery from "jquery";

const Navigation = {
  setActiveSection: function () {
    const path = window.location.pathname.replace(/#.*$/, "");
    jQuery('.nav a[href="' + path + '"]')
      .closest(".tab")
      .addClass("active");
  },
};

export default Navigation;
