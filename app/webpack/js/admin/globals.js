/**
 * Here we import things we want to be global (like jQuery plugins or similar classes)
 * So they can be accessed from views in a script tag
 *
 * An easy way to make them global is simply to stick them on window.
 **/

import AdminRoleManager from "./admin_role_manager";
import ApplicationEventsDetailsForm from "./application_events_details_form";
import ArtistsAdminIndex from "./artists_admin_index";
import MarkItDown from "./mark_it_down";
import MauDatatables from "./mau_datatables";
import OsKeyGenerator from "./os_key_generator";
import SlideToggler from "./slide_toggler";
import StudioArranger from "./studio_arranger";
import { GraphPerDay, PlainGraph } from "./graph_helpers";

const globals = {
  AdminRoleManager,
  ArtistsAdminIndex,
  ApplicationEventsDetailsForm,
  GraphPerDay,
  MarkItDown,
  MauDatatables,
  OsKeyGenerator,
  PlainGraph,
  SlideToggler,
  StudioArranger,
};

window.MAU = globals;
