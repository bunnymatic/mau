"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
/**
 * Maps a list to another list by combining lists.
 */
function flatMap(list, map) {
    return list.reduce(function (memo, item) { return memo.concat(map(item)); }, []);
}
exports.default = flatMap;
