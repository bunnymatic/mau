import SourceToken from 'coffee-lex/dist/SourceToken';
import DynamicMemberAccessOpPatcher from './DynamicMemberAccessOpPatcher';
import FunctionApplicationPatcher from './FunctionApplicationPatcher';
import MemberAccessOpPatcher from './MemberAccessOpPatcher';
export default class SoakedFunctionApplicationPatcher extends FunctionApplicationPatcher {
    patchAsExpression(): void;
    shouldPatchAsOptionalChaining(): boolean;
    shouldPatchAsConditional(): boolean;
    patchAsOptionalChaining(): void;
    patchAsConditional(): void;
    /**
     * Change a.b?() to __guardMethod__(a, 'b', o => o.b())
     */
    patchMethodCall(fn: MemberAccessOpPatcher): void;
    /**
     * Change a[b]?() to __guardMethod__(a, b, (o, m) => o[m]())
     */
    patchDynamicMethodCall(fn: DynamicMemberAccessOpPatcher): void;
    patchNonMethodCall(): void;
    getCallStartToken(): SourceToken;
}
