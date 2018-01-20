import NodePatcher from '../../../patchers/NodePatcher';
export default class ContinuePatcher extends NodePatcher {
    patchAsStatement(): void;
    canPatchAsExpression(): boolean;
}
