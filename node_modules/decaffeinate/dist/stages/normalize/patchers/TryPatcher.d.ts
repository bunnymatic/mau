import NodePatcher from '../../../patchers/NodePatcher';
import { PatcherContext } from '../../../patchers/types';
import BlockPatcher from './BlockPatcher';
export default class TryPatcher extends NodePatcher {
    body: BlockPatcher | null;
    catchAssignee: NodePatcher | null;
    catchBody: BlockPatcher | null;
    finallyBody: BlockPatcher | null;
    constructor(patcherContext: PatcherContext, body: BlockPatcher | null, catchAssignee: NodePatcher | null, catchBody: BlockPatcher | null, finallyBody: BlockPatcher | null);
    patchAsExpression(): void;
    patchCatchAssignee(): string | null;
    /**
     * Catch assignees in CoffeeScript can have (mostly) arbitrary assignees,
     * while JS is more limited. Generally JS only supports assignees that can
     * create variables.
     *
     * Also, JavaScript exception assignees are scoped to the catch block while
     * CoffeeScript exception assignees follow function scoping, so pull the
     * variable out into an assignment if the variable is used externally.
     */
    needsExpressionExtracted(): boolean;
}
