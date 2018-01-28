"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
function notNull(t) {
    if (t === null || t === undefined) {
        throw new Error('Unexpected null value.');
    }
    return t;
}
exports.default = notNull;
