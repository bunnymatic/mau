import * as svc from "@services/favorites.service";
import angular from "angular";

const favoritesService = () => {
  return svc;
};

angular.module("mau.services").factory("favoritesService", favoritesService);
