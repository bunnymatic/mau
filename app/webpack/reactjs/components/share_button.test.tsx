import { describe, expect, it } from "@jest/globals";
import { render, screen } from "@testing-library/react";
import React from "react";

import { ShareButton } from "./share_button";

describe("ShareButton", () => {
  const renderComponent = (type, artPiece = undefined) => {
    return render(<ShareButton artPiece={artPiece} type={type} />);
  };

  describe("when there is no art piece id", function () {
    it("renders nothing", function () {
      const { container } = renderComponent("facebook");
      expect(container).toBeEmptyDOMElement();
    });
  });

  describe("when it's a facebook share", function () {
    let artPiece = {
      id: 12,
      title: "Mona Lisa",
      artistName: "Leo",
      imageUrls: {
        large: "the_image.jpg",
      },
    };

    beforeEach(() => {
      renderComponent("facebook", artPiece);
    });

    it("includes the facebook icon", function () {
      const link = screen.getByTitle("Share this on Facebook");
      const icon = link.getElementsByTagName("I");
      expect(icon).toHaveLength(1);
      expect(icon[0].classList).toContain("fa-facebook");
      expect(link.href).toMatch(/\/\/www\.facebook\.com\/sharer\/sharer.php\?/);
      expect(link.href).toContain("localhost%3A%2Fart_pieces%2F12");
    });
  });

  describe("when it's a twitter share", function () {
    let artPiece = {
      id: 12,
      title: "Mona Lisa",
      artistName: "Leo",
      imageUrls: {
        large: "the_image.jpg",
      },
    };

    beforeEach(() => {
      renderComponent("twitter", artPiece);
    });

    it("includes the twitter icon", function () {
      const link = screen.getByTitle("Tweet this");
      const icon = link.getElementsByTagName("I");
      expect(icon).toHaveLength(1);
      expect(icon[0].classList).toContain("fa-twitter");
      expect(link.href).toMatch(/\/\/twitter\.com\/intent\/tweet\?/);
      expect(link.href).toContain(
        "text=Check+out+Mona+Lisa+by+Leo+on+Mission+Artists"
      );
      expect(link.href).toContain("&via=sfmau");
      expect(link.href).toMatch(/url=.*localhost%3A%2Fart_pieces%2F12/);
    });
  });

  describe("when it's a pinterest share", function () {
    let artPiece = {
      id: 12,
      title: "Mona Lisa",
      artistName: "Leo",
      imageUrls: {
        large: "the_image.jpg",
      },
    };

    beforeEach(() => {
      renderComponent("pinterest", artPiece);
    });

    it("includes the twitter icon", function () {
      const link = screen.getByTitle("Pin it");
      const icon = link.getElementsByTagName("I");
      expect(icon).toHaveLength(1);
      expect(icon[0].classList).toContain("fa-pinterest");
      expect(link.href).toMatch(/\/\/pinterest\.com\/pin\/create\/button\/?/);
      expect(link.href).toMatch(/url=.*localhost%3A%2Fart_pieces%2F12/);
      expect(link.href).toContain("title=Mona+Lisa");
      expect(link.href).toContain(
        "description=Check+out+Mona+Lisa+by+Leo+on+Mission+Artists"
      );
      expect(link.href).toContain("&media=the_image.jpg");
    });
  });
});
