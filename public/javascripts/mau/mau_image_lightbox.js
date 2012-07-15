var ILB = MAU.ImageLightbox = {};

ILB.settings = {
  main: 'img_modal',
  closeBtn: 'close-btn',
  modalWindow: 'img_modal_window',
  modalContent: 'img_modal_content',
  overlay: 'img_modal_overlay',
  imageContainer: 'img_container',
  image: {
    url: null, 
    width: null,
    height: null
  }
};

ILB = Object.extend(ILB, {
  init:function(opts) {
    this.container = $$('body')[0];
    console.log(opts);
    this.settings = Object.extend(this.settings, opts || {});
    this.hide();
  },
  show:function() {
    console.log(this.settings);
    var overlay = this.overlayHTML();
    var modal = this.modalHTML();
    this.container.appendChild(overlay);
    this.container.appendChild(modal);
  },
  hide:function() {
    if ($(this.settings.main)) {
      $(this.settings.main).remove();
    }
    if ($(this.settings.overlay)) {
      $(this.settings.overlay).remove();
    }
  },
  modalHTML: function() {
    var main = new Element('div', {id:this.settings.main});
    var modalWindow = new Element('div',{id:this.settings.modalWindow});
    var close = new Element("a", {href:'#', 'class':this.settings.closeBtn});
    close.html('x');
    close.observe('click', function(ev) {
      ILB.hide(); 
    });
    modalWindow.appendChild(close);
    var imgContainer = new Element('div', {'class':this.settings.imageContainer});
    var img = new Element('img', {
      src:this.settings.image.url, 
    });
    if (this.settings.image.width) {
      img.setAttribute('width', this.settings.image.width);
    }
    if (this.settings.image.height) {
      img.setAttribute('height', this.settings.image.height);
    }
    imgContainer.appendChild(img);
    var modalContent = new Element('div', {id:this.settings.modalContent});
    modalContent.appendChild(imgContainer);
    modalWindow.appendChild(modalContent);
    main.appendChild(modalWindow);
    return (main);
  },
  overlayHTML: function() {
    return (new Element('div', {id:this.settings.overlay}));
  }

});
