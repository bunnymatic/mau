/* eslint-disable */
/* import sorting blows this test setup */
import jQuery from "jquery";

jQuery.fx.speeds = { slow: 0, fast: 0, _default: 0 };

// gives us jest matchers (instead of vitest default Chai matchers)
import "@testing-library/jest-dom";
import { vi } from 'vitest'

const oldWindowLocation = window.location;

beforeAll(() => {
  delete window.location;

  window.location = Object.defineProperties(
    {},
    {
      ...Object.getOwnPropertyDescriptors(oldWindowLocation),
      assign: {
        configurable: true,
        value: vi.fn(),
      },
    }
  );
});
afterAll(() => {
  // restore `window.location` to the original `jsdom`
  // `Location` object
  window.location = oldWindowLocation;
});
