import React from "react";
import { render } from "react-dom";

import { lookup } from "../components";

// Find all components with class `react-component` and mount them
// This class name is used by `react_component` rails helper.  Make sure to keep them in sync
const REACT_COMPONENT_CLASS = "react-component";

function listAttributes(node) {
  const result = {};
  if (node.hasAttributes()) {
    const attrs = node.attributes;
    for (let i = attrs.length - 1; i >= 0; i--) {
      result[attrs[i].name] = attrs[i].value;
    }
  }
  return result;
}

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
      render(<Component {...props} />, node);
    });
  });
}
