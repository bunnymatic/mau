"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
/**
 * Rewriting a postfix if/while/for will fail if any intermediate expressions
 * use `then` or contain a newline. In both cases, surrounding the expression in
 * parens is enough to rearrange the code without introducing a parse error.
 */
function postfixExpressionRequiresParens(exprCode) {
    return exprCode.includes('then') || exprCode.includes('\n');
}
exports.default = postfixExpressionRequiresParens;
