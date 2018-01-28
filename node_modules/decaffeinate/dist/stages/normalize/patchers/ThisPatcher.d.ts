import PassthroughPatcher from '../../../patchers/PassthroughPatcher';
import { PatchOptions, RepeatableOptions } from '../../../patchers/types';
export default class ThisPatcher extends PassthroughPatcher {
    /**
     * When patching a shorthand like `@a` as repeatable, we need to add a dot to
     * make the result still syntactically valid.
     */
    patchAsRepeatableExpression(repeatableOptions?: RepeatableOptions, patchOptions?: PatchOptions): string;
}
