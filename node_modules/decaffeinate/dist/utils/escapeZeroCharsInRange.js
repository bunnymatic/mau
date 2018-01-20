"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
function escapeZeroCharsInRange(start, end, patcher) {
    var numBackslashes = 0;
    for (var i = start; i < end; i++) {
        if (patcher.context.source[i] === '\\') {
            numBackslashes++;
            continue;
        }
        else if (patcher.context.source[i] === '0' && numBackslashes % 2 === 1) {
            patcher.overwrite(i, i + 1, 'x00');
        }
        numBackslashes = 0;
    }
}
exports.default = escapeZeroCharsInRange;
