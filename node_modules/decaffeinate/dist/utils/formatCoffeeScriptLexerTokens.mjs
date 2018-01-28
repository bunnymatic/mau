import * as tslib_1 from "tslib";
import formatCoffeeScriptLocationData from './formatCoffeeScriptLocationData';
export default function formatCoffeeScriptLexerTokens(tokens, context) {
    var resultLines = tokens.map(function (_a) {
        var _b = tslib_1.__read(_a, 3), tag = _b[0], value = _b[1], locationData = _b[2];
        return formatCoffeeScriptLocationData(locationData, context) + ": " + tag + ": " + JSON.stringify(value);
    });
    return resultLines.map(function (line) { return line + '\n'; }).join('');
}
