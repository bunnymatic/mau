import { Block } from 'decaffeinate-parser/dist/nodes';
import NodePatcher from './NodePatcher';
import { PatcherContext } from './types';
export default class SharedBlockPatcher extends NodePatcher {
    node: Block;
    statements: Array<NodePatcher>;
    shouldPatchInline: boolean | null;
    constructor(patcherContext: PatcherContext, statements: Array<NodePatcher>);
    /**
     * Insert statements somewhere in this block.
     */
    insertStatementsAtIndex(statements: Array<string>, index: number): void;
    /**
     * Insert a statement before the current block. Since blocks can be patched in
     * a number of ways, this needs to handle a few cases:
     * - If it's completely inline, we don't deal with any indentation and just
     *   put a semicolon-separated statement before the start.
     * - If it's a normal non-inline block, we insert the statement beforehand
     *   with the given indentation. However, `this.outerStart` is the first
     *   non-whitespace character of the first line, so it's already indented, so
     *   if we want to add a line with *less* indentation, it's a lot more tricky.
     *   We handle this by walking backward to the previous newline and inserting
     *   a new line from there. This allows the prepended line to have whatever
     *   indentation level we want.
     * - In some cases, such as nontrivial loop expressions with an inline body,
     *   the source CoffeeScript is inline, but we want the result to be
     *   non-inline, so we need to be a lot more careful. The normal non-inline
     *   strategy won't work because there's no newline to walk back to in the
     *   source CoffeeScript, so the strategy is to instead always insert at
     *   `this.outerStart`. That means that the indentation for the actual body
     *   needs to be done later, just before the body itself is patched. See the
     *   uses of shouldConvertInlineBodyToNonInline in LoopPatcher for an example.
     */
    insertLineBefore(statement: string, indent?: string): void;
    insertLineAfter(statement: string, indent: string): void;
    /**
     * Gets whether this patcher's block is inline (on the same line as the node
     * that contains it) or not.
     */
    inline(): boolean;
}
