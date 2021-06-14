import Flash from "@js/app/flash";
import * as favoritesService from "@services/favorites.service";
import React, { FC } from "react";

interface FavoriteThisProps {
  type: string;
  id: number;
}

export const FavoriteThis: FC<FavoriteThisProps> = ({ type, id }) => {
  const flash = new Flash();
  const addFavorite = () => {
    favoritesService
      .add(type, id)
      .then((resp) => {
        flash.show({ notice: resp.message });
      })
      .catch((err) => {
        flash.show({
          error:
            err.message ||
            "Something went wrong trying to add that favorite.  Please tell us what you were trying to do so we can fix it.",
        });
      });
  };

  return (
    <a
      className="favorite-this"
      title="Add to your favorites"
      href="#"
      onClick={(e) => {
        e.preventDefault();
        addFavorite();
      }}
    >
      <div className="fa fa-ico-invert fa-heart-alt"></div>
    </a>
  );
};
