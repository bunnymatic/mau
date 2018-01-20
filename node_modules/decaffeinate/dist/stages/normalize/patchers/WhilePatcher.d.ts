import { While } from 'decaffeinate-parser/dist/nodes';
import NodePatcher from '../../../patchers/NodePatcher';
import { PatcherContext } from '../../../patchers/types';
/**
 * Normalizes `while` loops by rewriting post-`while` into standard `while`, e.g.
 *
 *   a() while b()
 *
 * becomes
 *
 *   while b() then a()
 */
export default class WhilePatcher extends NodePatcher {
    node: While;
    condition: NodePatcher;
    guard: NodePatcher | null;
    body: NodePatcher | null;
    constructor(patcherContext: PatcherContext, condition: NodePatcher, guard: NodePatcher | null, body: NodePatcher);
    patchAsExpression(): void;
    patchAsStatement(): void;
    /**
     * `BODY 'while' CONDITION ('when' GUARD)?` → `while CONDITION [when GUARD] then BODY`
     * `BODY 'until' CONDITION ('when' GUARD)?` → `until CONDITION [when GUARD] then BODY`
     *
     * @private
     */
    normalize(): void;
    /**
     * @private
     */
    isPostWhile(): boolean;
}
