import { PatchOptions } from '../../../patchers/types';
import UnaryOpPatcher from './UnaryOpPatcher';
export default class LogicalNotOpPatcher extends UnaryOpPatcher {
    /**
     * Though it's possible that `!` could trigger a `valueOf` call to arbitrary
     * code, CoffeeScript ignores that possibility and so do we.
     */
    isRepeatable(): boolean;
    /**
     * ( `!` | `not` ) EXPRESSION
     */
    patchAsExpression(options?: PatchOptions): void;
}
