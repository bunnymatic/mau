"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
var decaffeinate_parser_1 = require("decaffeinate-parser");
var nodes_1 = require("decaffeinate-parser/dist/nodes");
/**
 * Gets the number of usages of the given name in the given node.
 */
function countVariableUsages(node, name) {
    var numUsages = 0;
    decaffeinate_parser_1.traverse(node, function (child) {
        if (child instanceof nodes_1.Identifier && child.data === name) {
            numUsages += 1;
        }
    });
    return numUsages;
}
exports.default = countVariableUsages;
