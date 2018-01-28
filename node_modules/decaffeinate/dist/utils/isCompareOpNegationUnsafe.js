"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
/**
 * Determine if this operator is unsafe to convert under the getCompareOperator
 * algorithm. For example, `a < b` can't be negated to `a >= b` because it would
 * be incorrect if either variable is `NaN`.
 */
function isCompareOpNegationUnsafe(operator) {
    return ['<', '>', '<=', '>='].indexOf(operator) > -1;
}
exports.default = isCompareOpNegationUnsafe;
