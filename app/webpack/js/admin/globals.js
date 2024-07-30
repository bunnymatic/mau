/**
 * Here we import things we want to be global (like jQuery plugins or similar classes)
 * So they can be accessed from views in a script tag
 *
 * An easy way to make them global is simply to stick them on window.
 **/

import MauTimeago from "../app/mau_timeago";
import AdminRoleManager from "./admin_role_manager";
import ApplicationEventsDetailsForm from "./application_events_details_form";
import ArtistsAdminIndex from "./artists_admin_index";
import { GraphPerDay, PlainGraph } from "./graph_helpers";
import MarkItDown from "./mark_it_down";
import MauDatatables from "./mau_datatables";
import SlideToggler from "./slide_toggler";
import StudioArranger from "./studio_arranger";

const globals = {
  AdminRoleManager,
  ArtistsAdminIndex,
  ApplicationEventsDetailsForm,
  GraphPerDay,
  MarkItDown,
  MauDatatables,
  MauTimeago,
  PlainGraph,
  SlideToggler,
  StudioArranger,
};

window.MAU = globals;
