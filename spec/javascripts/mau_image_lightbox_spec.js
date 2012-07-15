var ILB = MAU.ImageLightbox;
describe('ImageLightbox', function() {
  describe('init', function() {
    it('sets the settings on the object', function() {
      ILB.init({overlay:'new_overlay'});
      expect(ILB.settings.overlay).toEqual('new_overlay');
    });
    it('sets defaults for the other settings', function() {
      ILB.init({overlay:'new_overlay'});
      expect(ILB.settings.main).toEqual('img_modal');
    });
  });
  describe('show', function() {
    var params = {overlay: 'this_overlay', main: "ilb_content", image:{url:'theimagefile'}};
    beforeEach(function() {
      ILB.init(params);
    });
    it("adds the overlay modal to the body", function() {
      ILB.show();
      expect($(params.overlay)).toBeTruthy();
    });
    it("adds the overlay content to the body", function() {
      ILB.show();
      expect($(params.main)).toBeTruthy();
    });
    it('includes an image container and image tag with the right image file', function() {
      ILB.show();
      expect($$('#' + params.main + ' .img_container img[src=theimagefile]').length).toEqual(1);
    });
  });
  describe('hide', function() {
    var params = {overlay: 'this_overlay', main: "ilb_content"};
    beforeEach(function() {
      ILB.init(params);
      ILB.show();
    });
    it("removes overlay divs", function() {
      ILB.hide();
      expect($(params.overlay)).toBeFalsy();
      expect($(params.main)).toBeFalsy();
    });
  });
  describe('close button', function() {
    beforeEach(function() {
      ILB.init();
      ILB.show();
    });
    it("clicking close hides the dialog", function() {
      expect($(ILB.settings.overlay)).toBeTruthy();
      jasmine.triggerEvent('#img_modal_window .close-btn', 'click');
      expect($(ILB.settings.overlay)).toBeFalsy();
    });
  });

});