import SourceToken from 'coffee-lex/dist/SourceToken';
import BinaryOpPatcher from './BinaryOpPatcher';
/**
 * Handles `extends` infix operator.
 */
export default class ExtendsOpPatcher extends BinaryOpPatcher {
    /**
     * CHILD extends PARENT
     */
    patchAsExpression(): void;
    /**
     * We always prefix with `__extends__`, so no need for parens.
     */
    statementNeedsParens(): boolean;
    operatorTokenPredicate(): (token: SourceToken) => boolean;
}
