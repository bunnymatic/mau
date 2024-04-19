import { camelizeKeys } from "humps";
import jQuery from "jquery";
import { beforeEach, describe, expect, it, vi } from "vitest";

import { api } from "./api";

describe("api", () => {
  const mockResp = { the_result: "is here" };
  beforeEach(() => {
    vi.resetAllMocks();
    vi.spyOn(jQuery, "ajaxSetup");
    vi.spyOn(jQuery, "ajax").mockResolvedValue(mockResp);
  });
  describe("notes", () => {
    describe("create", () => {
      it("calls the right endpoint", async () => {
        const resp = await api.notes.create({ the_key: "data" });
        expect(resp).toEqual(mockResp);
        expect(jQuery.ajax).toHaveBeenCalledWith({
          url: "/api/notes",
          method: "post",
          data: { the_key: "data" },
        });
      });
    });
  });
  describe("users", () => {
    describe("registerForOs", () => {
      it("calls the right endpoint", async () => {
        const resp = await api.users.registerForOs("the-slug", false);
        expect(resp).toEqual(camelizeKeys(mockResp));
        expect(jQuery.ajax).toHaveBeenCalledWith({
          url: "/api/artists/the-slug/register_for_open_studios",
          method: "post",
          data: { participation: false },
        });
      });
    });
    describe("whoami", () => {
      it("calls the right endpoint", async () => {
        const resp = await api.users.whoami();
        expect(resp).toEqual(camelizeKeys(mockResp));
        expect(jQuery.ajax).toHaveBeenCalledWith({
          url: "/users/whoami",
          method: "get",
          data: undefined,
        });
      });
    });
  });
  describe("search", () => {
    describe("query", () => {
      it("calls the right endpoint", async () => {
        const resp = await api.search.query({ whatever: "query" });
        expect(resp).toEqual(mockResp);
        expect(jQuery.ajax).toHaveBeenCalledWith({
          url: "/search.json",
          method: "post",
          data: { whatever: "query" },
        });
      });
    });
  });
  describe("emailLists", () => {
    describe("emails", () => {
      describe("index", () => {
        it("calls the right endpoint", async () => {
          const resp = await api.emailLists.emails.index(4);
          expect(resp).toEqual(camelizeKeys(mockResp));
          expect(jQuery.ajax).toHaveBeenCalledWith({
            url: "/admin/email_lists/4/emails",
            method: "get",
            data: undefined,
          });
        });
      });
      describe("save", () => {
        it("calls the right endpoint", async () => {
          const resp = await api.emailLists.emails.save(4, {
            email: "the-email",
          });
          expect(resp).toEqual(camelizeKeys(mockResp));
          expect(jQuery.ajax).toHaveBeenCalledWith({
            url: "/admin/email_lists/4/emails",
            method: "post",
            data: { email: "the-email" },
          });
        });
      });
      describe("destroy", () => {
        it("calls the right endpoint", async () => {
          const resp = await api.emailLists.emails.remove(6, 4);
          expect(resp).toEqual(camelizeKeys(mockResp));
          expect(jQuery.ajax).toHaveBeenCalledWith({
            url: "/admin/email_lists/4/emails/6",
            method: "delete",
            data: undefined,
          });
        });
      });
    });
  });
});
