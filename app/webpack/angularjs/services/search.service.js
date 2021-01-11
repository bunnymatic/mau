import { query } from "@js/services/search.service";
import angular from "angular";
angular.module("mau.services").factory("searchService", () => ({ query }));
