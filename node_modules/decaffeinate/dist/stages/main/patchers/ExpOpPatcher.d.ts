import BinaryOpPatcher from './BinaryOpPatcher';
/**
 * Handles exponentiation, i.e. `a ** b`.
 */
export default class ExpOpPatcher extends BinaryOpPatcher {
    /**
     * LEFT '**' RIGHT
     */
    patchAsExpression(): void;
    /**
     * We'll always start with `Math.pow` so we don't need parens.
     */
    statementNeedsParens(): boolean;
}
