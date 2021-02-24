import { FC } from "react";

import { Welcome } from "./admin/tests/welcome";
import { CreditsModal } from "./credits_modal";
import { Mailer } from "./mailer";
import { MauButton } from "./mau_button";
import { OpenStudiosRegistration } from "./open_studios_registration";

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
  CreditsModal,
  Mailer,
  MauButton,
  OpenStudiosRegistration,
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
