// go with maps
import "core-js/stable";
import "regenerator-runtime/runtime";

import AccordionShowSectionGivenHash from "./app/accordion_show_section_given_hash";
import AccordionShowSectionWithErrors from "./app/accordion_show_section_with_errors";
import ArrangeArtForm from "./app/arrange_art_form";
import ArtPieceForm from "./app/art_piece_form";
import ArtistBioToggler from "./app/artist_bio_toggler";
import ArtistDetailsToggler from "./app/artist_details_toggler";
import ArtistListInfiniteScroller from "./app/artist_list_infinite_scroller";
import BackToTop from "./app/back_to_top";
import MapResizer from "./app/map_resizer";
import MauMap from "./app/mau_map";
import MobileNavigation from "./app/mobile_navigation";
import Navigation from "./app/navigation";
import PasswordStrengthMeter from "./app/password_strength_meter";
import Sampler from "./app/sampler";
import WhatsThisPopup from "./app/whats_this_popup";

const globals = {
  AccordionShowSectionGivenHash,
  AccordionShowSectionWithErrors,
  ArrangeArtForm,
  ArtistBioToggler,
  ArtistDetailsToggler,
  ArtistListInfiniteScroller,
  ArtPieceForm,
  BackToTop,
  MauMap,
  MapResizer,
  MobileNavigation,
  Navigation,
  PasswordStrengthMeter,
  Sampler,
  WhatsThisPopup,
};
window.MAU = globals;
