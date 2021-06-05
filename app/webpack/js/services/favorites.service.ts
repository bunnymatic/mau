import { api } from "@services/api";
const MUST_LOGIN_MESSAGE = "You need to login before you can favorite things";

export const add = function (type: string, id: string | number) {
  return api.users
    .whoami()
    .then(function ({ currentUser: { slug } }) {
      return api.favorites
        .add(slug, type, id)
        .then(function ({ message }) {
          return {
            message:
              message ||
              "Great choice for a favorite!  We added it to your collection.",
          };
        })
        .catch(function ({ message }) {
          return {
            message:
              message ||
              "That item doesn't seem to be available to favorite.  If you think it should be, please drop us a note and we'll look into it.",
          };
        });
    })
    .catch((_err) => ({
      message: MUST_LOGIN_MESSAGE,
    }));
};
