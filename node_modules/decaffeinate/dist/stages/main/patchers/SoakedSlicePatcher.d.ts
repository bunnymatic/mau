import SlicePatcher from './SlicePatcher';
export default class SoakedSlicePatcher extends SlicePatcher {
    patchAsExpression(): void;
    /**
     * For a soaked splice operation, we are the soak container.
     */
    getSpliceCode(expressionCode: string): string;
    shouldPatchAsOptionalChaining(): boolean;
}
