"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
var tslib_1 = require("tslib");
// tslint:disable-next-line:no-any
function logger(name) {
    if (isLoggingEnabled(name)) {
        return function () {
            var args = [];
            for (var _i = 0; _i < arguments.length; _i++) {
                args[_i] = arguments[_i];
            }
            return console.log.apply(console, tslib_1.__spread([name], args));
        };
    }
    else {
        return function () { };
    }
}
exports.logger = logger;
function isLoggingEnabled(name) {
    return !!process.env["DEBUG:" + name] || !!process.env['DEBUG:*'];
}
