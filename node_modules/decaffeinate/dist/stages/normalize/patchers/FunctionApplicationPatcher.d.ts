import SourceToken from 'coffee-lex/dist/SourceToken';
import { PatcherContext } from '../../../patchers/types';
import NodePatcher from './../../../patchers/NodePatcher';
export default class FunctionApplicationPatcher extends NodePatcher {
    fn: NodePatcher;
    args: Array<NodePatcher>;
    constructor(patcherContext: PatcherContext, fn: NodePatcher, args: Array<NodePatcher>);
    patchAsExpression(): void;
    /**
     * We need to be careful when inserting the close-paren after a function call,
     * since an incorrectly-placed close-paren can cause a parsing error in the
     * MainStage due to subtle indentation rules in the CoffeeScript parser.
     *
     * In particular, we prefer to place the close paren after an existing } or ],
     * or before an existing ), if we can, since that is least likely to confuse
     * any indentation parsing. But in some cases it's best to instead insert the
     * close-paren properly-indented on its own line.
     */
    insertImplicitCloseParen(): void;
    getFollowingCloseParenIfExists(): SourceToken | null;
    /**
     * Normally we can edit up to the end of our editing bounds (but no further),
     * but be especially careful here to not place a close-paren before the
     * indentation level of our statement.
     */
    getMaxCloseParenInsertPoint(): number;
    /**
     * Determine if parens need to be inserted. Needs to handle implicit soaked
     * function calls (where there's a question mark between the function and the
     * args).
     *
     * Note that we do not add parentheses for constructor invocations with no
     * arguments and no parentheses; that usage is correct in JavaScript, so we
     * leave it as-is.
     */
    isImplicitCall(): boolean;
    /**
     * Get the source index after the function and the question mark, if any.
     * This is the start of the region to insert an open-paren if necessary
     */
    getFuncEnd(): number;
}
