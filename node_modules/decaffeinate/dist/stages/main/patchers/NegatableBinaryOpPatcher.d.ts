import NodePatcher from '../../../patchers/NodePatcher';
import { PatcherContext } from '../../../patchers/types';
import BinaryOpPatcher from './BinaryOpPatcher';
/**
 * Handles `instanceof` operator, e.g. `a instanceof b`.
 */
export default class NegatableBinaryOpPatcher extends BinaryOpPatcher {
    negated: boolean;
    constructor(patcherContext: PatcherContext, left: NodePatcher, right: NodePatcher);
    negate(): void;
    javaScriptOperator(): string;
    /**
     * LEFT 'not'? OP RIGHT
     */
    patchAsExpression(): void;
    /**
     * It may be wrapped due to negation, so don't double-wrap.
     */
    statementNeedsParens(): boolean;
}
