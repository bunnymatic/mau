"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
/**
 * Determines whether the given node spans multiple lines.
 */
function isMultiline(source, node) {
    var newlineIndex = source.indexOf('\n', node.start);
    return newlineIndex >= 0 && newlineIndex < node.end;
}
exports.default = isMultiline;
