import SourceTokenListIndex from 'coffee-lex/dist/SourceTokenListIndex';
import { While } from 'decaffeinate-parser/dist/nodes';
import { PatcherContext } from '../../../patchers/types';
import NodePatcher from './../../../patchers/NodePatcher';
import BlockPatcher from './BlockPatcher';
import LoopPatcher from './LoopPatcher';
/**
 * Handles `while` loops, e.g.
 *
 *   while a
 *     b
 */
export default class WhilePatcher extends LoopPatcher {
    node: While;
    condition: NodePatcher;
    guard: NodePatcher | null;
    constructor(patcherContext: PatcherContext, condition: NodePatcher, guard: NodePatcher | null, body: BlockPatcher);
    initialize(): void;
    /**
     * ( 'while' | 'until' ) CONDITION ('when' GUARD)? 'then' BODY
     * ( 'while' | 'until' ) CONDITION ('when' GUARD)? NEWLINE INDENT BODY
     */
    patchAsStatement(): void;
    /**
     * @private
     */
    getWhileTokenIndex(): SourceTokenListIndex;
    /**
     * @private
     */
    getThenTokenIndex(): SourceTokenListIndex | null;
    getLoopBodyIndent(): string;
    willPatchAsIIFE(): boolean;
}
