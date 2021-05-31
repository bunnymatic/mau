import * as types from "@reactjs/types";
import { destroy, get, post, put } from "@services/mau_ajax";
import { camelizeKeys } from "humps";

const camelize = (data) => camelizeKeys(data);

export const api = {
  openStudios: {
    submitRegistrationStatus: (status: boolean) => {
      return api.users.whoami().then(function ({ currentUser }) {
        if (currentUser && currentUser.slug) {
          return api.users.registerForOs(currentUser.slug, status);
        }
      });
    },
    participants: {
      update: ({
        id,
        artistId,
        openStudiosParticipant,
      }: types.OpenStudiosParticipantUpdateRequest) => {
        return put(`/api/artists/${artistId}/open_studios_participants/${id}`, {
          openStudiosParticipant,
        }).then(camelize);
      },
    },
  },
  artPieces: {
    contact: (id: types.IdType, formData: types.ContactArtistFormData) => {
      return post(`/api/v2/art_pieces/${id}/contact`, formData).then(camelize);
    },
  },
  applicationEvents: {
    index: ({ since }): Promise<types.ApplicationEventsListResponse> =>
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
    registerForOs: (artistSlug, status) => {
      const url = `/api/artists/${artistSlug}/register_for_open_studios`;
      return post(url, { participation: status }).then(camelize);
    },
    whoami: () => get("/users/whoami").then(camelize),
  },
};
