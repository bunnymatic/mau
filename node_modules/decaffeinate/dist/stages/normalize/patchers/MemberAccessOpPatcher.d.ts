import { MemberAccessOp } from 'decaffeinate-parser/dist/nodes';
import NodePatcher, { AddThisAssignmentCallback } from '../../../patchers/NodePatcher';
import PassthroughPatcher from '../../../patchers/PassthroughPatcher';
import { PatcherContext } from '../../../patchers/types';
import IdentifierPatcher from './IdentifierPatcher';
export default class MemberAccessOpPatcher extends PassthroughPatcher {
    node: MemberAccessOp;
    expression: NodePatcher;
    member: IdentifierPatcher;
    constructor(patcherContext: PatcherContext, expression: NodePatcher, member: IdentifierPatcher);
    shouldTrimContentRange(): boolean;
    patch(): void;
    findAddThisAssignmentCallback(): AddThisAssignmentCallback | null;
}
