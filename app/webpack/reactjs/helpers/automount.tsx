import React from "react";
import { createRoot } from "react-dom/client";

import { lookup } from "../components";

// Find all components with class `react-component` and mount them
// This class name is used by `react_component` rails helper.  Make sure to keep them in sync
const REACT_COMPONENT_CLASS = "react-component";

export function automount() {
  document.addEventListener("DOMContentLoaded", function () {
    const els = Array.from(
      document.getElementsByClassName(REACT_COMPONENT_CLASS)
    );
    els.forEach(function (node) {
      const componentClass = node.getAttribute("data-component");
      const propsJSON = node.getAttribute("data-react-props") || "{}";
      const Component = lookup(componentClass);
      const props = JSON.parse(propsJSON);
      const root = createRoot(node);
      root.render(<Component {...props} />);
    });
  });
}
