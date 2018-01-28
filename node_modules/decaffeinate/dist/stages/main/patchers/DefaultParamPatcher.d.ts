import NodePatcher from '../../../patchers/NodePatcher';
import { PatcherContext } from '../../../patchers/types';
export default class DefaultParamPatcher extends NodePatcher {
    param: NodePatcher;
    value: NodePatcher;
    constructor(patcherContext: PatcherContext, param: NodePatcher, value: NodePatcher);
    initialize(): void;
    patchAsExpression(): void;
}
