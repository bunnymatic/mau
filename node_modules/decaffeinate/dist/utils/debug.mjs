import * as tslib_1 from "tslib";
// tslint:disable-next-line:no-any
export function logger(name) {
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
function isLoggingEnabled(name) {
    return !!process.env["DEBUG:" + name] || !!process.env['DEBUG:*'];
}
