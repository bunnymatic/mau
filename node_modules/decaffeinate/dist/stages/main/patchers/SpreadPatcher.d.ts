import { PatcherContext } from '../../../patchers/types';
import NodePatcher from './../../../patchers/NodePatcher';
/**
 * Handles spread operations, e.g. `a(b...)` or `[a...]`.
 */
export default class SpreadPatcher extends NodePatcher {
    expression: NodePatcher;
    constructor(patcherContext: PatcherContext, expression: NodePatcher);
    initialize(): void;
    setAssignee(): void;
    /**
     * We need to move the `...` from the right to the left and wrap the
     * expression in Array.from, since CS allows array-like objects and JS
     * requires iterables.
     */
    patchAsExpression(): void;
    needsArrayFrom(): boolean;
}
