import { traverse } from 'decaffeinate-parser';
import { Identifier } from 'decaffeinate-parser/dist/nodes';
/**
 * Gets the number of usages of the given name in the given node.
 */
export default function countVariableUsages(node, name) {
    var numUsages = 0;
    traverse(node, function (child) {
        if (child instanceof Identifier && child.data === name) {
            numUsages += 1;
        }
    });
    return numUsages;
}
