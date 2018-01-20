"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
var getStartOfLine_1 = require("./getStartOfLine");
/**
 * Gets the indent string for the line containing offset.
 */
function getIndent(source, offset) {
    var startOfLine = getStartOfLine_1.default(source, offset);
    var indentOffset = startOfLine;
    var indentCharacter;
    switch (source[indentOffset]) {
        case ' ':
        case '\t':
            indentCharacter = source[indentOffset];
            break;
        default:
            return '';
    }
    while (source[indentOffset] === indentCharacter) {
        indentOffset++;
    }
    return source.slice(startOfLine, indentOffset);
}
exports.default = getIndent;
