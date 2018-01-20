import NodePatcher from './../../../patchers/NodePatcher';
export default class ThisPatcher extends NodePatcher {
    patchAsExpression(): void;
    isShorthandThis(): boolean;
    isRepeatable(): boolean;
    reportTopLevelThisIfNecessary(): void;
}
