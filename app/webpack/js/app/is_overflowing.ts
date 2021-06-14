export class IsOverflowing {
  el: HTMLElement;

  constructor(el: HTMLElement) {
    this.el = el;
  }

  test() {
    return (
      this.el.scrollHeight > this.el.offsetHeight ||
      this.el.scrollWidth > this.el.offsetWidth
    );
  }
}
