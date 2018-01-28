import NodePatcher from '../../../patchers/NodePatcher';
import { PatcherContext } from '../../../patchers/types';
import BlockPatcher from './BlockPatcher';
import ForPatcher from './ForPatcher';
export default class ForInPatcher extends ForPatcher {
    step: NodePatcher | null;
    constructor(patcherContext: PatcherContext, keyAssignee: NodePatcher | null, valAssignee: NodePatcher | null, target: NodePatcher, step: NodePatcher | null, filter: NodePatcher | null, body: BlockPatcher);
    patchAsExpression(): void;
    surroundThenUsagesInParens(): void;
}
