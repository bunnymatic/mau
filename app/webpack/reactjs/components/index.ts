import { FC } from "react";

import { EmailListManager } from "./admin/email_list_manager";
import { Welcome } from "./admin/tests/welcome";
import { ArtCard } from "./art_card";
import { ArtModal } from "./art_modal";
import { ArtPage } from "./art_page";
import { ArtPieceBrowser } from "./art_piece_browser";
import { ConfirmModal } from "./confirm_modal";
import { CreditsModal } from "./credits_modal";
import { EditableContentTrigger } from "./editable_content_trigger";
import { EventsNotificationBell } from "./events_notification_bell";
import { Mailer } from "./mailer";
import { MauButton } from "./mau_button";
import { NotifyMauDialog } from "./notify_mau_dialog";
import { OpenStudiosRegistrationSection } from "./open_studios/open_studios_registration_section";
import { ReactTestComponent } from "./react_test_component";
import { Search } from "./search";

class UnregisteredComponentError extends Error {
  constructor(message) {
    super(message);
    this.name = "UnregisteredComponentError";
  }
}

/**
this serves as the registry.  All react components
that will be mounted at their root should be included here.
**/
const reactComponents = {
  ArtCard,
  ArtModal,
  ArtPage,
  ArtPieceBrowser,
  ConfirmModal,
  CreditsModal,
  EditableContentTrigger,
  EmailListManager,
  EventsNotificationBell,
  Mailer,
  MauButton,
  NotifyMauDialog,
  OpenStudiosRegistrationSection,
  ReactTestComponent,
  Search,
  Welcome,
};

export const lookup = (componentName: string): FC<any> => {
  if (!(componentName in reactComponents)) {
    throw new UnregisteredComponentError(
      `Unable to find component ${componentName}.  Has it been registered in the reactComponents index?`
    );
  }
  return reactComponents[componentName];
};
