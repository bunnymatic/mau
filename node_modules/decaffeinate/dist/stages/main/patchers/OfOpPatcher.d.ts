import SourceToken from 'coffee-lex/dist/SourceToken';
import NegatableBinaryOpPatcher from './NegatableBinaryOpPatcher';
/**
 * Handles `of` operators, e.g. `a of b` and `a not of b`.
 */
export default class OfOpPatcher extends NegatableBinaryOpPatcher {
    operatorTokenPredicate(): (token: SourceToken) => boolean;
    javaScriptOperator(): string;
}
