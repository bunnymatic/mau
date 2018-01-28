import SourceTokenListIndex from 'coffee-lex/dist/SourceTokenListIndex';
import NodePatcher from '../../../patchers/NodePatcher';
import { PatcherContext } from '../../../patchers/types';
/**
 * Normalizes conditionals by rewriting post-`if` into standard `if`, e.g.
 *
 *   return [] unless list?
 *
 * becomes
 *
 *   unless list? then return []
 */
export default class ConditionalPatcher extends NodePatcher {
    condition: NodePatcher;
    consequent: NodePatcher | null;
    alternate: NodePatcher | null;
    constructor(patcherContext: PatcherContext, condition: NodePatcher, consequent: NodePatcher, alternate: NodePatcher | null);
    patchAsExpression(): void;
    /**
     * `CONSEQUENT 'if' CONDITION` → `if CONDITION then CONSEQUENT`
     * `CONSEQUENT 'unless' CONDITION` → `unless CONDITION then CONSEQUENT`
     */
    patchPostIf(): void;
    isPostIf(): boolean;
    getIfTokenIndex(): SourceTokenListIndex;
}
