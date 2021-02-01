import { Welcome } from "./admin/tests/welcome";
import { Mailer } from "./mailer";

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
  Mailer,
  Welcome,
};

export const lookup = (componentName: string): FC<any> => {
  if (!(componentName in reactComponents)) {
    throw new UnregisteredComponentError(`Unable to find component ${componentName}.  Has it been registered in the reactComponents index?`)
  }
  return reactComponents[componentName]
}
