import { PatcherContext } from '../../../patchers/types';
import NodePatcher from './../../../patchers/NodePatcher';
export default class ThrowPatcher extends NodePatcher {
    expression: NodePatcher;
    constructor(patcherContext: PatcherContext, expression: NodePatcher);
    initialize(): void;
    /**
     * Throw in JavaScript is a statement only, so we'd prefer it stay that way.
     */
    prefersToPatchAsExpression(): boolean;
    /**
     * Throw statements that are in the implicit return position should simply
     * be left alone as they're pure statements in JS and don't have a value.
     */
    setImplicitlyReturns(): void;
    /**
     * `throw` statements cannot normally be used as expressions, so we wrap them
     * in an arrow function IIFE.
     */
    patchAsExpression(): void;
    patchAsStatement(): void;
    /**
     * This is here so that we can add the `()` outside any existing parens.
     */
    allowPatchingOuterBounds(): boolean;
}
