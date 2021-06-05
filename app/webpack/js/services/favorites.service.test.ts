import { api } from "@services/api";
import expect from "expect";

import * as service from "./favorites.service";

jest.mock("@services/api");

describe("mau.services.favoriteService", function () {
  beforeEach(function () {
    jest.resetAllMocks();
  });

  describe(".add", function () {
    it("calls the right endpoint to add this favorite if there is a logged in user", async function () {
      const type = "Artist";
      const id = "12";
      const success = {
        message: "eat at joes",
      };
      api.users.whoami = jest.fn().mockResolvedValue({
        currentUser: {
          id: 1,
          login: "the_user",
          slug: "the_user_slug",
        },
      });
      api.favorites.add = jest.fn().mockResolvedValue(success);
      const data = await service.add(type, id);

      expect(data.message).toEqual("eat at joes");
      expect(api.users.whoami).toHaveBeenCalled();
      expect(api.favorites.add).toHaveBeenCalledWith("the_user_slug", type, id);
    });
    it("returns a message if there is not a logged in user", async function () {
      api.users.whoami = jest.fn().mockResolvedValue({});
      const data = await service.add("the_type", "the_id");
      expect(data.message).toEqual(
        "You need to login before you can favorite things"
      );
      expect(api.users.whoami).toHaveBeenCalled();
      expect(api.favorites.add).not.toHaveBeenCalled();
    });
    it("returns a message if there is favoriting fails", async function () {
      api.users.whoami = jest.fn().mockResolvedValue({
        currentUser: {
          id: 1,
          login: "somebody",
          slug: "somebody_slug",
        },
      });
      api.favorites.add = jest.fn().mockRejectedValue({});
      const data = await service.add(null, null);
      expect(data).toEqual({
        message:
          "That item doesn't seem to be available to favorite.  If you think it should be, please drop us a note and we'll look into it.",
      });
      expect(api.users.whoami).toHaveBeenCalled();
      expect(api.favorites.add).not.toHaveBeenCalledWith("xxx");
    });
  });
});
