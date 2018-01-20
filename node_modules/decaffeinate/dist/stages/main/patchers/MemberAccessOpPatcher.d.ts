import SourceToken from 'coffee-lex/dist/SourceToken';
import { MemberAccessOp } from 'decaffeinate-parser/dist/nodes';
import { PatcherContext, PatchOptions, RepeatableOptions } from '../../../patchers/types';
import NodePatcher from './../../../patchers/NodePatcher';
import IdentifierPatcher from './IdentifierPatcher';
export default class MemberAccessOpPatcher extends NodePatcher {
    node: MemberAccessOp;
    expression: NodePatcher;
    member: IdentifierPatcher;
    _skipImplicitDotCreation: boolean;
    constructor(patcherContext: PatcherContext, expression: NodePatcher, member: IdentifierPatcher);
    initialize(): void;
    setSkipImplicitDotCreation(): void;
    patchAsExpression(): void;
    /**
     * We can make member accesses repeatable by making the base expression
     * repeatable if it isn't already.
     */
    patchAsRepeatableExpression(repeatableOptions?: RepeatableOptions, patchOptions?: PatchOptions): string;
    hasImplicitOperator(): boolean;
    getMemberOperatorSourceToken(): SourceToken | null;
    getMemberName(): string;
    getFullMemberName(): string;
    getMemberNameSourceToken(): SourceToken;
    /**
     * Member access is repeatable (in CoffeeScript) if the expression we're
     * accessing a member of is also repeatable. Technically speaking even this is
     * not safe since member access can have side-effects via getters and setters,
     * but this is the way the official CoffeeScript compiler works so we follow
     * suit.
     */
    isRepeatable(): boolean;
    /**
     * If `BASE` needs parens, then `BASE.MEMBER` needs parens.
     */
    statementNeedsParens(): boolean;
    lhsNeedsParens(): boolean;
}
