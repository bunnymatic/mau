import SourceToken from 'coffee-lex/dist/SourceToken';
import { Range } from 'decaffeinate-parser/dist/nodes';
import BinaryOpPatcher from './BinaryOpPatcher';
export default class RangePatcher extends BinaryOpPatcher {
    node: Range;
    patchAsExpression(): void;
    /**
     * @private
     */
    patchAsLiteralArray(): void;
    /**
     * @private
     */
    patchAsIIFE(): void;
    /**
     * @private
     */
    canBecomeLiteralArray(): boolean;
    /**
     * @private
     */
    getLiteralRange(): [number, number] | null;
    /**
     * @private
     */
    isInclusive(): boolean;
    operatorTokenPredicate(): (token: SourceToken) => boolean;
}
