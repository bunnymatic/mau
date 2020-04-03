import expect from "expect";
import jQuery from "jquery";
import "./jquery.feedback.js";

jest.dontMock("jquery");

describe("jquery.Feedback", function () {
  beforeEach(function () {
    document.documentElement.innerHTML =
      '<div id="fixture"><div class="feedback-link">feedback me</div></div>';
    jQuery("#fixture .feedback-link").feedback();
  });

  it("clicking it shows the modal", () => {
    jQuery(".feedback-link").click();
    expect(
      jQuery("#feedback #feedback_modal_window #feedback_modal_content")
    ).toHaveLength(1);
  });
});
