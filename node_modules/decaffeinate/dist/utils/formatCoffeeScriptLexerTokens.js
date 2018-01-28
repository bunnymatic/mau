"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
var tslib_1 = require("tslib");
var formatCoffeeScriptLocationData_1 = require("./formatCoffeeScriptLocationData");
function formatCoffeeScriptLexerTokens(tokens, context) {
    var resultLines = tokens.map(function (_a) {
        var _b = tslib_1.__read(_a, 3), tag = _b[0], value = _b[1], locationData = _b[2];
        return formatCoffeeScriptLocationData_1.default(locationData, context) + ": " + tag + ": " + JSON.stringify(value);
    });
    return resultLines.map(function (line) { return line + '\n'; }).join('');
}
exports.default = formatCoffeeScriptLexerTokens;
