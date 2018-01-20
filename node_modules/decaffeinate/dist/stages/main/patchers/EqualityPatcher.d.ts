import SourceToken from 'coffee-lex/dist/SourceToken';
import BinaryOpPatcher from './BinaryOpPatcher';
/**
 * Handles equality and inequality comparisons.
 */
export default class EqualityPatcher extends BinaryOpPatcher {
    negated: boolean;
    patchOperator(): void;
    getCompareOperator(): string;
    /**
     * @private
     */
    getCompareToken(): SourceToken;
    /**
     * Flips negated flag but doesn't edit anything immediately so that we can
     * use the correct operator in `patch`. If the negation is unsafe, fall back
     * to the superclass default behavior of just adding ! to the front.
     */
    negate(): void;
}
