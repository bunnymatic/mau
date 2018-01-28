import SourceToken from 'coffee-lex/dist/SourceToken';
import { PatcherContext } from '../../../patchers/types';
import NodePatcher from './../../../patchers/NodePatcher';
/**
 * Handles array or string slicing, e.g. `names[i..]`.
 */
export default class SlicePatcher extends NodePatcher {
    expression: NodePatcher;
    left: NodePatcher | null;
    right: NodePatcher | null;
    /**
     * `node` is of type `Slice`.
     */
    constructor(patcherContext: PatcherContext, expression: NodePatcher, left: NodePatcher | null, right: NodePatcher | null);
    initialize(): void;
    shouldPatchAsOptionalChaining(): boolean;
    /**
     * EXPRESSION '[' LEFT? ( .. | ... ) RIGHT? ']'
     */
    patchAsExpression(): void;
    /**
     * Given the RHS of a splice expression, return the code for it. This only
     * happens in a context where our expression will go away, so children can be
     * patched as necessary.
     */
    getSpliceCode(expressionCode: string): string;
    /**
     * Patch into the first part of a splice expression. For example,
     *
     * a[b...c]
     *
     * becomes
     *
     * a.splice(b, c - b
     *
     * The enclosing assignment operator patcher will do the rest.
     */
    patchAsSpliceExpressionStart(): void;
    /**
     * @private
     */
    isInclusive(): boolean;
    /**
     * @private
     */
    getIndexStartSourceToken(): SourceToken;
    /**
     * @private
     */
    getSliceSourceToken(): SourceToken;
    /**
     * @private
     */
    getIndexEndSourceToken(): SourceToken;
    /**
     * If `BASE` needs parens then `BASE[0..1]` needs parens.
     */
    statementNeedsParens(): boolean;
}
