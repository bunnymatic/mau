import * as ReactDOM from "react-dom";
import * as React from "react";

export default function mount(Component, mountNodeId) {
  document.addEventListener('DOMContentLoaded', () => {
    const mountNode = document.getElementById(mountNodeId);
    const propsJSON = mountNode.getAttribute('data-react-props');
    const props = JSON.parse(propsJSON);

    ReactDOM.render(
      <Component {...props} />, mountNode);
  })
}
