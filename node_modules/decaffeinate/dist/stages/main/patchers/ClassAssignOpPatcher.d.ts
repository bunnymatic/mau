import { Node } from 'decaffeinate-parser/dist/nodes';
import { PatcherClass } from '../../../patchers/NodePatcher';
import ClassPatcher from './ClassPatcher';
import ObjectBodyMemberPatcher from './ObjectBodyMemberPatcher';
export default class ClassAssignOpPatcher extends ObjectBodyMemberPatcher {
    static patcherClassForChildNode(node: Node, property: string): PatcherClass | null;
    /**
     * Don't put semicolons after methods.
     */
    statementNeedsSemicolon(): boolean;
    patchAsExpression(): void;
    /**
     * If the method name is computed, we'll need to repeat it for any super call
     * that we do, so mark it as repeatable now.
     */
    markKeyRepeatableIfNecessary(): void;
    /**
     * @protected
     */
    patchKey(): void;
    /**
     * @protected
     */
    patchAsProperty(): void;
    /**
     * Determines if this class assignment matches the known patterns for static
     * methods in CoffeeScript, i.e.
     *
     *   class A
     *     this.a: ->
     *     @b: ->
     *     A.c: ->
     *
     * Similarly, `this[a]`, `@[b]`, and `A[c]` can all become static methods.
     *
     * @protected
     */
    isStaticMethod(): boolean;
    getEnclosingClassPatcher(): ClassPatcher;
    isBoundInstanceMethod(): boolean;
    /**
     * For classes, unlike in objects, manually bound methods can use regular
     * method syntax because the bind happens in the constructor.
     *
     * @protected
     */
    isMethod(): boolean;
}
