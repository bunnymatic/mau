import SourceToken from 'coffee-lex/dist/SourceToken';
import NodePatcher from '../../../patchers/NodePatcher';
import { PatcherContext } from '../../../patchers/types';
import BlockPatcher from './BlockPatcher';
export default class ForPatcher extends NodePatcher {
    keyAssignee: NodePatcher | null;
    valAssignee: NodePatcher | null;
    target: NodePatcher;
    filter: NodePatcher | null;
    body: BlockPatcher;
    constructor(patcherContext: PatcherContext, keyAssignee: NodePatcher | null, valAssignee: NodePatcher | null, target: NodePatcher, filter: NodePatcher | null, body: BlockPatcher);
    patchAsExpression(): void;
    patchAsStatement(): void;
    /**
     * Patch the value assignee, and if we need to add a line to the start of the
     * body, return that line. Otherwise, return null.
     */
    patchValAssignee(): string | null;
    /**
     * @private
     */
    isPostFor(): boolean;
    /**
     * Defensively wrap expressions in parens if they might contain a `then`
     * token, since that would mess up the parsing when we rearrange the for loop.
     *
     * This method can be subclassed to account for additional fields.
     */
    surroundThenUsagesInParens(): void;
    /**
     * @private
     */
    getForToken(): SourceToken;
    /**
     * @private
     */
    getFirstHeaderPatcher(): NodePatcher;
}
