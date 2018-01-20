import SourceToken from 'coffee-lex/dist/SourceToken';
import NodePatcher from '../../../patchers/NodePatcher';
import { PatcherContext } from '../../../patchers/types';
import BinaryOpPatcher from './BinaryOpPatcher';
/**
 * Handles `in` operators, e.g. `a in b` and `a not in b`.
 */
export default class InOpPatcher extends BinaryOpPatcher {
    negated: boolean;
    /**
     * `node` is of type `InOp`.
     */
    constructor(patcherContext: PatcherContext, left: NodePatcher, right: NodePatcher);
    negate(): void;
    operatorTokenPredicate(): (token: SourceToken) => boolean;
    /**
     * LEFT 'in' RIGHT
     */
    patchAsExpression(): void;
    patchWithLHSExtracted(): void;
    shouldWrapInArrayFrom(): boolean;
    rhsNeedsParens(): boolean;
    patchAsIndexLookup(): void;
    /**
     * Method invocations don't need parens.
     */
    statementNeedsParens(): boolean;
}
