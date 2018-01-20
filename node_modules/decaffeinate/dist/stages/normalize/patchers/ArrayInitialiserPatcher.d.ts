import { PatcherContext } from '../../../patchers/types';
import NodePatcher from './../../../patchers/NodePatcher';
export default class ArrayInitialiserPatcher extends NodePatcher {
    members: Array<NodePatcher>;
    constructor(patcherContext: PatcherContext, members: Array<NodePatcher>);
    patchAsExpression(): void;
}
