import SourceToken from 'coffee-lex/dist/SourceToken';
import { PatcherContext } from '../../../patchers/types';
import NodePatcher from './../../../patchers/NodePatcher';
/**
 * Handles sequence expressions/statements, e.g `a; b`.
 */
export default class SeqOpPatcher extends NodePatcher {
    left: NodePatcher;
    right: NodePatcher;
    negated: boolean;
    constructor(patcherContext: PatcherContext, left: NodePatcher, right: NodePatcher);
    negate(): void;
    /**
     * LEFT ';' RIGHT
     */
    patchAsExpression(): void;
    /**
     * If we're patching as a statement, we can just keep the semicolon or newline.
     */
    patchAsStatement(): void;
    getOperatorToken(): SourceToken;
    statementNeedsParens(): boolean;
}
