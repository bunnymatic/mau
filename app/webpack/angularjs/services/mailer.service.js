import { mailToLink } from "@js/services/mailer.service";
import angular from "angular";
const mailerService = () => ({ mailToLink });

angular.module("mau.services").factory("mailerService", mailerService);
