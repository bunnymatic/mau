import BinaryOpPatcher from './BinaryOpPatcher';
/**
 * Handles logical AND and logical OR.
 *
 * This class is primarily responsible for rewriting `and` to `&&` and `or` to
 * `||`. It also applies De Morgan's laws [1] in the event of negation, such as
 * when used as the condition of an `unless` expression:
 *
 *   a unless b && c  # equivalent to `a if !b || !c`
 *
 * [1]: https://en.wikipedia.org/wiki/De_Morgan%27s_laws
 */
export default class LogicalOpPatcher extends BinaryOpPatcher {
    negated: boolean;
    patchOperator(): void;
    /**
     * Apply De Morgan's law.
     *
     * @private
     */
    getOperator(): string;
    negate(): void;
}
