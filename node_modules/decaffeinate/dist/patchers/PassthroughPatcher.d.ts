import NodePatcher from './NodePatcher';
import { PatcherContext } from './types';
export default class PassthroughPatcher extends NodePatcher {
    children: Array<NodePatcher | Array<NodePatcher> | null>;
    constructor(patcherContext: PatcherContext, ...children: Array<NodePatcher | Array<NodePatcher> | null>);
    patchAsExpression(): void;
    isRepeatable(): boolean;
}
