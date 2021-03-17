import ngInject from "@angularjs/ng-inject";
import { routing } from "@js/services/routing.service";
import angular from "angular";

const objectRoutingService = ngInject(function () {
  return routing;
});

angular
  .module("mau.services")
  .factory("objectRoutingService", objectRoutingService);
