import SourceTokenListIndex from 'coffee-lex/dist/SourceTokenListIndex';
import NodePatcher from '../../../patchers/NodePatcher';
import { PatcherContext } from '../../../patchers/types';
import FunctionPatcher from './FunctionPatcher';
export default class DoOpPatcher extends NodePatcher {
    expression: NodePatcher;
    constructor(patcherContext: PatcherContext, expression: NodePatcher);
    initialize(): void;
    patchAsExpression(): void;
    /**
     * Determine whether there is a "do function"--that is, a function where we
     * should change default params to arguments to the do call.
     */
    hasDoFunction(): boolean;
    getDoFunction(): FunctionPatcher;
    /**
     * @private
     */
    getDoTokenIndex(): SourceTokenListIndex;
}
