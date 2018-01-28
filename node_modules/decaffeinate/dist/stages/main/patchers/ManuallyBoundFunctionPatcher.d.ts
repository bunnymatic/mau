import { PatchOptions } from '../../../patchers/types';
import FunctionPatcher from './FunctionPatcher';
/**
 * Handles bound functions that cannot become arrow functions.
 */
export default class ManuallyBoundFunctionPatcher extends FunctionPatcher {
    patchAsStatement(options?: PatchOptions): void;
    patchAsExpression(options?: PatchOptions): void;
    expectedArrowType(): string;
}
