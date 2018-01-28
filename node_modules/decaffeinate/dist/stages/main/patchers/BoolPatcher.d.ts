import NodePatcher from './../../../patchers/NodePatcher';
export default class BoolPatcher extends NodePatcher {
    patchAsExpression(): void;
    isRepeatable(): boolean;
}
