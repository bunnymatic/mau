"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
var determineIndent_1 = require("./determineIndent");
var getIndent_1 = require("./getIndent");
/**
 * Adjust an indent in source at a specific offset by an amount.
 */
function adjustIndent(source, offset, adjustment) {
    var currentIndent = getIndent_1.default(source, offset);
    var determinedIndent = determineIndent_1.default(source);
    if (adjustment > 0) {
        while (adjustment--) {
            currentIndent += determinedIndent;
        }
    }
    else if (adjustment < 0) {
        currentIndent = currentIndent.slice(determinedIndent.length * -adjustment);
    }
    return currentIndent;
}
exports.default = adjustIndent;
