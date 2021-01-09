import { destroy, get, post } from "@js/services/mau_ajax";
import { camelizeKeys } from "humps";

const camelize = (data) => camelizeKeys(data);

export const api = {
  applicationEvents: {
    index: ({ since }) =>
      get("/admin/application_events.json", { "query[since]": since }).then(
        camelize
      ),
  },
  emailLists: {
    emails: {
      index: (emailListId) =>
        get(`/admin/email_lists/${emailListId}/emails`).then(camelize),
      save: (emailListId, data) =>
        post(`/admin/email_lists/${emailListId}/emails`, data).then(camelize),
      remove: (id, emailListId) =>
        destroy(`/admin/email_lists/${emailListId}/emails/${id}`).then(
          camelize
        ),
    },
  },
  favorites: {
    add: (userSlug, type, id) => {
      const url = `/users/${userSlug}/favorites`;
      return post(url, { favorite: { type, id } });
    },
  },

  notes: {
    create: (data) => post("/api/notes", data),
  },
  search: {
    query: (queryParams) => {
      return post("/search.json", queryParams);
    },
  },
  users: {
    registerForOs: (artistSlug, data) => {
      const url = `/api/artists/${artistSlug}/register_for_open_studios`;
      return post(url, data).then(camelize);
    },
    whoami: () => get("/users/whoami").then(camelize),
  },
};
