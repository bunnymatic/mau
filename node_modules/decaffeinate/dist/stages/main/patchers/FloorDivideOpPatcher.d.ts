import BinaryOpPatcher from './BinaryOpPatcher';
export default class FloorDivideOpPatcher extends BinaryOpPatcher {
    /**
     * LEFT '//' RIGHT
     */
    patchAsExpression(): void;
    /**
     * We always prefix with `Math.floor`, so no need for parens.
     */
    statementNeedsParens(): boolean;
}
