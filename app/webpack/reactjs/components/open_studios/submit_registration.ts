import Flash from "@js/app/jquery/flash";
import { api } from "@js/services/api";

export const submitRegistration = (registering: boolean) => {
  return api.openStudios.submitRegistrationStatus(registering).catch(() => {
    new Flash.show({
      error:
        "We had problems updating your open studios status.  Please try again later",
    });
  });
};
