import NodePatcher from '../../../patchers/NodePatcher';
import { PatcherContext } from '../../../patchers/types';
import ClassPatcher from './ClassPatcher';
export declare type EarlySuperTransformInfo = {
    classCode: string;
    accessCode: string;
};
export default class AssignOpPatcher extends NodePatcher {
    assignee: NodePatcher;
    expression: NodePatcher;
    constructor(patcherContext: PatcherContext, assignee: NodePatcher, expression: NodePatcher);
    patchAsExpression(): void;
    isDynamicallyCreatedClassAssignment(): boolean;
    patchClassAssignmentPrefix(): void;
    patchClassAssignmentOperator(): void;
    /**
     * If we are within a class body (not a method), return that class.
     */
    getClassParent(): ClassPatcher | null;
    /**
     * Dynamically-created static methods using super need to be transformed in
     * the normalize stage instead of the main stage. Otherwise, the `super` will
     * resolve to `initClass` instead of the proper static method.
     */
    needsEarlySuperTransform(): boolean;
    prepareEarlySuperTransform(): void;
    getEarlySuperTransformInfo(): EarlySuperTransformInfo | null;
    /**
     * Assignment operators are allowed to have a `then` token after them for some
     * reason, and it doesn't do anything, so just get rid of it.
     */
    removeUnnecessaryThenToken(): void;
}
