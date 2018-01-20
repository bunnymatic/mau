import SoakedFunctionApplicationPatcher from './SoakedFunctionApplicationPatcher';
export default class SoakedNewOpPatcher extends SoakedFunctionApplicationPatcher {
    /**
     * Since `new` makes a new `this`, don't bother with the `guardMethod` variant.
     */
    patchMethodCall(): void;
    /**
     * Since `new` makes a new `this`, don't bother with the `guardMethod` variant.
     */
    patchDynamicMethodCall(): void;
}
