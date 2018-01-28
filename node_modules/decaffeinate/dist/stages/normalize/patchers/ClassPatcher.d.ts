import NodePatcher from './../../../patchers/NodePatcher';
import BlockPatcher from './BlockPatcher';
import { BaseAssignOp, Node } from 'decaffeinate-parser/dist/nodes';
import { PatcherContext } from '../../../patchers/types';
export declare type NonMethodInfo = {
    patcher: NodePatcher;
    deleteStart: number;
};
export declare type CustomConstructorInfo = {
    ctorName: string;
    expressionCode: string;
};
export default class ClassPatcher extends NodePatcher {
    nameAssignee: NodePatcher | null;
    superclass: NodePatcher | null;
    body: BlockPatcher | null;
    constructor(patcherContext: PatcherContext, nameAssignee: NodePatcher | null, parent: NodePatcher | null, body: BlockPatcher | null);
    /**
     * Handle code within class bodies by restructuring the class to use a static
     * method instead.
     *
     * Current limitations:
     * - Doesn't deconflict the "initClass" name of the static method.
     * - Technically this changes the execution order of the class body, although
     *   it does so in a way that is unlikely to cause problems in reasonable
     *   code.
     */
    patchAsStatement(): void;
    /**
     * For now, code in class bodies is only supported for statement classes.
     */
    patchAsExpression(): void;
    needsIndent(): boolean;
    needsInitClass(): boolean;
    removeThenTokenIfNecessary(): void;
    shouldUseIIFE(): boolean;
    getInitClassInsertPoint(): number;
    /**
     * Find the statements in the class body that can't be converted to JS
     * methods. These will later be moved to the top of the class in a static
     * method.
     */
    getNonMethodPatchers(): Array<NonMethodInfo>;
    isClassMethod(patcher: NodePatcher): boolean;
    isClassAssignment(node: Node): node is BaseAssignOp;
    needsCustomConstructor(): boolean;
    /**
     * Constructors in CoffeeScript can be arbitrary expressions, so if that's the
     * case, we need to save that expression so we can compute it at class init
     * time and call it from the real constructor. If this is such a case, pick a
     * name for the constructor, get the code to evaluate the constructor
     * function, and overwrite the constructor with a function that forwards to
     * that constructor function.
     */
    extractCustomConstructorInfo(): CustomConstructorInfo | null;
    /**
     * Create the initClass static method by moving nodes from the class body into
     * the static method and indenting them one level.
     *
     * Also return an array of variables that were assigned so that later code can
     * declare them outside the class body to make them accessible within the
     * class.
     */
    generateInitClassMethod(nonMethodPatchers: Array<NonMethodInfo>, customConstructorInfo: CustomConstructorInfo | null, insertPoint: number): Array<string>;
    hasAnyAssignments(nonMethodPatchers: Array<NonMethodInfo>): boolean;
    getBodyIndent(): string;
    /**
     * Determine the variable assigned in the given statement, if any, since any
     * assigned variables need to be declared externally so they are available
     * within the class body. Note that this is incomplete at the moment and only
     * covers the common case of a single variable being defined.
     */
    getAssignmentName(statementPatcher: NodePatcher): string | null;
}
