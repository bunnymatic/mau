import SourceToken from 'coffee-lex/dist/SourceToken';
import AssignOpPatcher from './AssignOpPatcher';
export default class CompoundAssignOpPatcher extends AssignOpPatcher {
    getOperatorToken(): SourceToken;
    /**
     * If `LHS` needs parens then `LHS += RHS` needs parens.
     */
    statementNeedsParens(): boolean;
    /**
     * If the left-hand side of the assignment has a soak operation, then there
     * may be a __guard__ call surrounding the whole thing, so we can't patch
     * statement code, so instead run the expression code path.
     */
    lhsHasSoakOperation(): boolean;
}
