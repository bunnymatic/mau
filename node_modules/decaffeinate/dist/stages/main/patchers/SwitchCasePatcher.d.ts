import SourceToken from 'coffee-lex/dist/SourceToken';
import NodePatcher from '../../../patchers/NodePatcher';
import { PatcherContext } from '../../../patchers/types';
export default class SwitchCasePatcher extends NodePatcher {
    conditions: Array<NodePatcher>;
    consequent: NodePatcher | null;
    negated: boolean;
    constructor(patcherContext: PatcherContext, conditions: Array<NodePatcher>, consequent: NodePatcher);
    initialize(): void;
    patchAsStatement(): void;
    setImplicitlyReturns(): void;
    patchAsExpression(): void;
    /**
     * Don't actually negate the conditions until just before patching, since
     * otherwise we might accidentally overwrite a ! character that gets inserted.
     */
    negate(): void;
    /**
     * @private
     */
    getWhenToken(): SourceToken;
    /**
     * @private
     */
    getCommaTokens(): Array<SourceToken>;
    /**
     * @private
     */
    hasExistingBreak(): boolean;
    /**
     * Gets the token representing the `then` between condition and consequent.
     *
     * @private
     */
    getThenToken(): SourceToken | null;
}
