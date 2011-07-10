require('spec_helper.js');
require('../../vendor/plugins/blue-ridge/vendor/jquery-1.4.2.js');
jQuery.noConflict();
require("../../public/javascripts/prototype/1.6.0.3/prototype.all.min.js");
require("../../public/javascripts/mau.js");



Screw.Unit(function(){
  var test_data = {"art_piece":{"image_height":1022,"medium":{"name":"Mixed-Media","created_at":{"n":0,"json_class":"Time","s":1260344533},"updated_at":{"n":0,"json_class":"Time","s":1260344533},"id":2},"created_at":{"n":0,"json_class":"Time","s":1271555666},"title":"Bunnymatic Sparkles","dimensions":"34&#x22; x 36&#x22;","updated_at":{"n":0,"json_class":"Time","s":1290220428},"tags":[{"name":"sparkles","created_at":{"n":0,"json_class":"Time","s":1271555666},"updated_at":{"n":0,"json_class":"Time","s":1271555666},"id":848},{"name":"bunnymatic","created_at":{"n":0,"json_class":"Time","s":1260345432},"updated_at":{"n":0,"json_class":"Time","s":1260345432},"id":1}],"order":0,"medium_id":2,"id":1632,"image_width":800,"year":2009,"filename":"artistdata/1/imgs/1271555666bunnymaticsparkleswindow_small.jpg","description":null,"favorites_count":0,"artist_id":1}};
  
  var test_data2 = {"art_piece":{"image_height":1022,"medium":{"name":"Mixed-Media","created_at":{"n":0,"json_class":"Time","s":1260344533},"updated_at":{"n":0,"json_class":"Time","s":1260344533},"id":2},"created_at":{"n":0,"json_class":"Time","s":1271555666},"title":"Bunnymatic Sparkles","dimensions":"34&#x22; x 36&#x22;","updated_at":{"n":0,"json_class":"Time","s":1290220428},"tags":[{"name":"sparkles","created_at":{"n":0,"json_class":"Time","s":1271555666},"updated_at":{"n":0,"json_class":"Time","s":1271555666},"id":848},{"name":"bunnymatic","created_at":{"n":0,"json_class":"Time","s":1260345432},"updated_at":{"n":0,"json_class":"Time","s":1260345432},"id":1}],"order":0,"medium_id":2,"id":1632,"image_width":800,"year":2009,"filename":"public/artistdata/1/imgs/1271555666bunnymaticsparkleswindow_small.jpg","description":null,"favorites_count":0,"artist_id":1}};

  describe("Thumbs.Helpers", function() {
    describe("filename with leading public", function() {
      it("computes medium art piece path", function(){
        var apfname = test_data2['art_piece'].filename;
        var f = MAU.Thumbs.Helpers.get_image_path(apfname, 'medium');
        expect(f).to(equal,'/artistdata/1/imgs/m_1271555666bunnymaticsparkleswindow_small.jpg');
      });
      it("computes small art piece path", function(){
        var apfname = test_data2['art_piece'].filename;
        var f = MAU.Thumbs.Helpers.get_image_path(apfname, 'small');
        expect(f).to(equal,'/artistdata/1/imgs/s_1271555666bunnymaticsparkleswindow_small.jpg');
      });
      it("computes thumb art piece path", function(){
        var apfname = test_data2['art_piece'].filename;
        var f = MAU.Thumbs.Helpers.get_image_path(apfname, 'thumb');
        expect(f).to(equal,'/artistdata/1/imgs/t_1271555666bunnymaticsparkleswindow_small.jpg');
      });
      it("does nothing for bad size", function(){
        var apfname = test_data2['art_piece'].filename;
        var f = MAU.Thumbs.Helpers.get_image_path(apfname, 'bogus');
        expect(f).to(equal,'public/artistdata/1/imgs/1271555666bunnymaticsparkleswindow_small.jpg');
      });
    });
    describe("filename without leading public", function() {
      it("computes medium art piece path", function(){
        var apfname = test_data['art_piece'].filename;
        var f = MAU.Thumbs.Helpers.get_image_path(apfname, 'medium');
        expect(f).to(equal,'/artistdata/1/imgs/m_1271555666bunnymaticsparkleswindow_small.jpg');
      });
      it("computes small art piece path", function(){
        var apfname = test_data['art_piece'].filename;
        var f = MAU.Thumbs.Helpers.get_image_path(apfname, 'small');
        expect(f).to(equal,'/artistdata/1/imgs/s_1271555666bunnymaticsparkleswindow_small.jpg');
      });
      it("computes thumb art piece path", function(){
        var apfname = test_data['art_piece'].filename;
        var f = MAU.Thumbs.Helpers.get_image_path(apfname, 'thumb');
        expect(f).to(equal,'/artistdata/1/imgs/t_1271555666bunnymaticsparkleswindow_small.jpg');
      });
      it("does nothing for bad size", function(){
        var apfname = test_data['art_piece'].filename;
        var f = MAU.Thumbs.Helpers.get_image_path(apfname, 'bogus');
        expect(f).to(equal,'artistdata/1/imgs/1271555666bunnymaticsparkleswindow_small.jpg');
      });
    });
  });
});

