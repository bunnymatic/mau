import SourceToken from 'coffee-lex/dist/SourceToken';
import NodePatcher from './../../../patchers/NodePatcher';
export declare type MethodInfo = {
    classCode: string | null;
    accessCode: string | null;
};
/**
 * Transform CS super to JS super. For constructors, we can keep the form
 * `super(a, b, c)`, but for methods, we need to insert the method name, e.g.
 * `super.foo(a, b, c)`. However, there are some cases where CS allows super
 * calls but JS doesn't, so in those cases, we find the class and method name
 * using CS's algorithm and insert a more direct prototype method call.
 */
export default class SuperPatcher extends NodePatcher {
    patchAsExpression(): void;
    /**
     * @private
     */
    getEnclosingMethodInfo(): MethodInfo;
    /**
     * @private
     */
    getEnclosingClassName(patcher: NodePatcher): string | null;
    /**
     * @private
     */
    getEnclosingMethodAssignment(): NodePatcher;
    /**
     * Extract the 'A' and 'b' from a node like `A.prototype.b = -> c`, if it
     * matches that form. Return null otherwise.
     *
     * @private
     */
    getPrototypeAssignInfo(patcher: NodePatcher): MethodInfo | null;
    /**
     * JavaScript super is more limited than CoffeeScript super, so in some cases
     * we need to write out an expanded version that uses the method on the
     * prototype. In particular:
     *
     * - CoffeeScript allows method assignments like `A::b = -> super`, and is
     *   able to determine the class and method name from code written like this.
     * - CoffeeScript allows `super` from nested methods (which end up compiling
     *   to use whatever `arguments` is relevant at that point in code if the
     *   `super` is written without args).
     *
     * @private
     */
    canConvertToJsSuper(): boolean;
    /**
     * @private
     */
    getEnclosingFunction(): NodePatcher;
    /**
     * @private
     */
    getFollowingOpenParenToken(): SourceToken;
}
