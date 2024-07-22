import { Spinner as SpinJS } from "spin.js";
import { beforeEach, describe, expect, it, vi } from "vitest";

import Spinner from "./spinner";

vi.mock("spin.js");

const mockSpin = vi.fn();
const mockStop = vi.fn();
SpinJS.prototype.spin = mockSpin;
SpinJS.prototype.stop = mockStop;

describe("Spinner", function () {
  let spinner;

  beforeEach(() => {
    vi.resetAllMocks();
    document.documentElement.innerHTML =
      '<div id="fixture">' + `<div class="spin-goes-here"></div>` + "</div>";

    spinner = new Spinner({ element: ".spin-goes-here" });
  });

  it("spins when you call spin", () => {
    spinner.spin();
    expect(mockSpin).toHaveBeenCalled();
  });

  it("stops the spinner when you've called stop (if it's been started)", () => {
    spinner.spin();
    spinner.stop();
    expect(mockStop).toHaveBeenCalled();
  });

  it("stops does nothing if you haven't already called spin", () => {
    spinner.stop();
    expect(mockStop).not.toHaveBeenCalled();
  });
});
