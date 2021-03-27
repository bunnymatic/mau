import { get } from "@services/mau_ajax";
import jQuery from "jquery";

class ArtistListInfiniteScroller {
  constructor(url) {
    this.fetching = false;

    const $win = jQuery(window);
    $win.scroll(() => {
      if ($win.scrollTop() === jQuery(document).height() - $win.height()) {
        return this.fetchArtists(url);
      }
    });
    const $more = jQuery("#js-scroll-load-more");
    if ($more.length && $more.position().top < $win.height()) {
      return this.fetchArtists(url);
    }
  }

  async fetchArtists(url) {
    if (this.fetching) {
      return;
    }
    this.fetching = true;

    let nextPage;
    let $content = jQuery(".js-artists-scroll-wrapper");
    const pagination = jQuery(".js-pagination-state").last().data();
    if (pagination.hasMore) {
      nextPage = pagination.nextPage;
      const data = await get(url, {
        s: pagination.sortOrder,
        l: pagination.currentLetter,
        p: nextPage,
        os_only: pagination.osOnly,
      });

      jQuery("#js-scroll-load-more").remove();
      if (data) {
        $content = jQuery(".js-artists-scroll-wrapper");
        $content.append(data);
      }
      return (this.fetching = false);
    }
  }
}

export default ArtistListInfiniteScroller;
