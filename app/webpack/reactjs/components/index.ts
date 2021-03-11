import { FC } from "react";

import { Welcome } from "./admin/tests/welcome";
import { ConfirmModal } from "./confirm_modal";
import { CreditsModal } from "./credits_modal";
import { Mailer } from "./mailer";
import { MauButton } from "./mau_button";
import { OpenStudiosRegistrationSection } from "./open_studios/open_studios_registration_section";

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
export const reactComponents = {
  ConfirmModal,
  CreditsModal,
  Mailer,
  MauButton,
  OpenStudiosRegistrationSection,
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
