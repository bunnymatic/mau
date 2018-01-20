import NodePatcher from '../../../patchers/NodePatcher';
import { PatcherContext } from '../../../patchers/types';
import BinaryOpPatcher from './BinaryOpPatcher';
export default class ModuloOpPatcher extends BinaryOpPatcher {
    /**
     * `node` is of type `ModuloOp`.
     */
    constructor(patcherContext: PatcherContext, left: NodePatcher, right: NodePatcher);
    patchAsExpression(): void;
    /**
     * We always prefix with `__mod__` so no parens needed.
     */
    statementNeedsParens(): boolean;
}
