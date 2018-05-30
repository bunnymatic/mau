describe("Utils", function() {
  describe("createElement", function() {
    it("builds a div with a class and id", function() {
      var dv = MAU.Utils.createElement("div", {
        class: "my-class",
        id: "my-id"
      });
      expect(dv.id).toEqual("my-id");
      expect(dv.getAttribute("class")).toEqual("my-class");
    });
  });
});
