import NodePatcher from '../../../patchers/NodePatcher';
import { PatcherContext } from '../../../patchers/types';
import BlockPatcher from './BlockPatcher';
/**
 * Normalizes `loop` loops by rewriting into standard `while`, e.g.
 *
 *   loop
 *     b()
 *
 * becomes
 *
 *   while true
 *     b()
 */
export default class LoopPatcher extends NodePatcher {
    body: BlockPatcher;
    constructor(patcherContext: PatcherContext, body: BlockPatcher);
    patchAsExpression(): void;
}
