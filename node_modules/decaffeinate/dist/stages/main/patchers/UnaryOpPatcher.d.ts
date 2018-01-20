import { PatcherContext, PatchOptions } from '../../../patchers/types';
import NodePatcher from './../../../patchers/NodePatcher';
export default class UnaryOpPatcher extends NodePatcher {
    expression: NodePatcher;
    constructor(patcherContext: PatcherContext, expression: NodePatcher);
    initialize(): void;
    /**
     * OP EXPRESSION
     */
    patchAsExpression(options?: PatchOptions): void;
    /**
     * If `EXPRESSION` needs parens then `EXPRESSION OP` needs parens.
     */
    statementNeedsParens(): boolean;
}
