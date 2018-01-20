import NodePatcher from '../../../patchers/NodePatcher';
import { PatcherContext, PatchOptions } from '../../../patchers/types';
import ClassBlockPatcher from './ClassBlockPatcher';
import ClassPatcher from './ClassPatcher';
import FunctionPatcher from './FunctionPatcher';
import ObjectBodyMemberPatcher from './ObjectBodyMemberPatcher';
export default class ConstructorPatcher extends ObjectBodyMemberPatcher {
    expression: FunctionPatcher;
    _bindings: Array<string> | null;
    constructor(patcherContext: PatcherContext, assignee: NodePatcher, expression: FunctionPatcher);
    patch(options?: PatchOptions): void;
    getLinesToInsert(): Array<string>;
    /**
     * Give an up-front error if this is a subclass that either omits the `super`
     * call or uses `this` before `super`.
     */
    checkForConstructorErrors(): void;
    shouldAddBabelWorkaround(): boolean;
    /**
     * Return a string with an error if this constructor is invalid (generally one
     * that uses this before super). Otherwise return null.
     */
    getInvalidConstructorMessage(): string | null;
    getBindings(): Array<string>;
    getEnclosingClassPatcher(): ClassPatcher;
    getEnclosingClassBlockPatcher(): ClassBlockPatcher;
    getIndexOfSuperStatement(): number;
    getIndexOfFirstThisStatement(): number;
    /**
     * Don't put semicolons after class constructors.
     */
    statementNeedsSemicolon(): boolean;
}
