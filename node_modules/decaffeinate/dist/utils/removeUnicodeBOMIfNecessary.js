"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
/**
 * If the source code starts with a Unicode BOM, CoffeeScript will just ignore
 * it and provide source code locations that assume that it was removed, so we
 * should do the same.
 */
function removeUnicodeBOMIfNecessary(source) {
    if (source[0] === '\uFEFF') {
        return source.slice(1);
    }
    else {
        return source;
    }
}
exports.default = removeUnicodeBOMIfNecessary;
