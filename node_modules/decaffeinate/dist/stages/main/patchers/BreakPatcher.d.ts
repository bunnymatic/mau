import NodePatcher from '../../../patchers/NodePatcher';
export default class BreakPatcher extends NodePatcher {
    patchAsStatement(): void;
    canPatchAsExpression(): boolean;
}
