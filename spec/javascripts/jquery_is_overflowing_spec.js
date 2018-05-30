// Generated by CoffeeScript 1.12.7
(function() {
  describe("jQuery.isOverflowing", function() {
    return describe("with default initialization", function() {
      beforeEach(function() {
        return fixture.set(
          "<div class='overflow' style='overflow: hidden; height:40px; width: 40px;'>A</div>"
        );
      });
      it("is not overflowing with a small amount of content", function() {
        return expect(jQuery(".overflow").isOverflowing()).toBeFalsy();
      });
      return it("is overflowing with lots of content", function() {
        jQuery(".overflow").html(
          "this should be <br/> enough content to make that div overflow<br/>"
        );
        return expect(jQuery(".overflow").isOverflowing()).toBeTruthy();
      });
    });
  });
}.call(this));
