"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
/**
 * Finds the start of the line for the character at offset.
 */
function getStartOfLine(source, offset) {
    var lfIndex = source.lastIndexOf('\n', offset - 1);
    if (lfIndex < 0) {
        return 0;
    }
    return lfIndex + 1;
}
exports.default = getStartOfLine;
