import expect from "expect";
import jQuery from "jquery";
import AccountTypeChooser from "./account_type_chooser";
import "@js/app/spinner";

jest.dontMock("jquery");

const mockSpin = jest.fn();
jest.mock("@js/app/spinner", () => {
  return jest.fn().mockImplementation(() => {
    return { spin: mockSpin };
  });
});

describe("AccountTypeChooser", function () {
  let windowSpy;
  let location = { href: "whatever" };
  beforeEach(() => {
    windowSpy = jest.spyOn(global, "window", "get");

    windowSpy.mockImplementation(() => ({
      location: location,
    }));
  });

  afterEach(() => {
    windowSpy.mockRestore();
  });

  beforeEach(() => {
    document.documentElement.innerHTML =
      '<div id="fixture">' +
      '<select class="chooser">' +
      '  <option value="">&lt;select your account type&gt;</option>' +
      '  <option value="Type1">Mission Art Fan</option>' +
      '  <option value="Type2">Mission Artist</option>' +
      "</select>" +
      "</div>";

    new AccountTypeChooser("select.chooser");
  });

  it("when the value changes it starts a spinner and resets the location.href", () => {
    jQuery(".chooser [value=Type2]").attr("selected", "selected");
    jQuery(".chooser").trigger("change");

    expect(mockSpin).toHaveBeenCalled();
    expect(window.location.href).toEqual(
      "http://localhost/users/new?type=Type2"
    );
  });
});
