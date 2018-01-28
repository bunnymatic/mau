import NodePatcher, { AddDefaultParamCallback } from '../../../patchers/NodePatcher';
import PassthroughPatcher from '../../../patchers/PassthroughPatcher';
import { PatcherContext } from '../../../patchers/types';
export default class DefaultParamPatcher extends PassthroughPatcher {
    param: NodePatcher;
    value: NodePatcher;
    constructor(patcherContext: PatcherContext, param: NodePatcher, value: NodePatcher);
    patch(): void;
    findAddDefaultParamAssignmentCallback(): AddDefaultParamCallback | null;
    /**
     * For correctness reasons, we usually need to extract the assignment into a
     * statement that checks null and undefined rather than just undefined. But
     * skip that step if the user opted out of it in favor of cleaner code, and
     * also in a case like `do (a=1) -> a`, which is handled later as a special
     * case and doesn't use JS default params.
     *
     * Also skip the conversion when the default is to `null`, since the behavior
     * between CoffeeScript and JavaScript happens to be the same in that case.
     */
    shouldExtractToConditionalAssign(): boolean;
}
