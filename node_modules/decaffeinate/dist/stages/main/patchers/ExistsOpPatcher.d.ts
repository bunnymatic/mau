import BinaryOpPatcher from './BinaryOpPatcher';
export default class ExistsOpPatcher extends BinaryOpPatcher {
    /**
     * If we are a statement, the RHS should be patched as a statement.
     */
    rhsMayBeStatement(): boolean;
    setExpression(force: boolean): boolean;
    /**
     * LEFT '?' RIGHT → `LEFT != null ? LEFT : RIGHT`
     */
    patchAsExpression(): void;
    /**
     * LEFT '?' RIGHT → `if (LEFT == null) { RIGHT }`
     */
    patchAsStatement(): void;
    /**
     * We'll always start with an `if` so we don't need parens.
     */
    statementNeedsParens(): boolean;
}
