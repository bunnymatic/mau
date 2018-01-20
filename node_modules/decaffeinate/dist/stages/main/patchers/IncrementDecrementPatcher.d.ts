import NodePatcher from '../../../patchers/NodePatcher';
import { PatcherContext } from '../../../patchers/types';
export default class IncrementDecrementPatcher extends NodePatcher {
    expression: NodePatcher;
    constructor(patcherContext: PatcherContext, expression: NodePatcher);
    initialize(): void;
    patchAsExpression(): void;
    isRepeatable(): boolean;
}
