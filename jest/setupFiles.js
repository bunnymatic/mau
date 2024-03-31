/* eslint-disable */
/* import sorting blows this test setup */
import jQuery from "jquery";

jest.dontMock("jquery");

jQuery.fx.speeds = { slow: 0, fast: 0, _default: 0 };

import "@testing-library/jest-dom";

const oldWindowLocation = window.location;

beforeAll(() => {
  delete window.location;

  window.location = Object.defineProperties(
    {},
    {
      ...Object.getOwnPropertyDescriptors(oldWindowLocation),
      assign: {
        configurable: true,
        value: jest.fn(),
      },
    }
  );
});
afterAll(() => {
  // restore `window.location` to the original `jsdom`
  // `Location` object
  window.location = oldWindowLocation;
});
