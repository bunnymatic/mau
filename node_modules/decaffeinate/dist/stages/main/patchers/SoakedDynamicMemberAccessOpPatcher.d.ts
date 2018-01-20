import NodePatcher from '../../../patchers/NodePatcher';
import { PatcherContext } from '../../../patchers/types';
import DynamicMemberAccessOpPatcher from './DynamicMemberAccessOpPatcher';
export default class SoakedDynamicMemberAccessOpPatcher extends DynamicMemberAccessOpPatcher {
    _shouldSkipSoakPatch: boolean;
    constructor(patcherContext: PatcherContext, expression: NodePatcher, indexingExpr: NodePatcher);
    patchAsExpression(): void;
    shouldPatchAsOptionalChaining(): boolean;
    shouldPatchAsConditional(): boolean;
    patchAsOptionalChaining(): void;
    patchAsConditional(): void;
    patchAsGuardCall(): void;
    setShouldSkipSoakPatch(): void;
}
