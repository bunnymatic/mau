import { PatcherContext } from '../../../patchers/types';
import NodePatcher from './../../../patchers/NodePatcher';
export default class ReturnPatcher extends NodePatcher {
    expression: NodePatcher | null;
    constructor(patcherContext: PatcherContext, expression: NodePatcher | null);
    initialize(): void;
    /**
     * Return statements cannot be expressions.
     */
    canPatchAsExpression(): boolean;
    patchAsStatement(): void;
    willConvertToImplicitReturn(): boolean;
}
