import { Node } from 'decaffeinate-parser/dist/nodes';
import { PatchOptions } from '../../../patchers/types';
import { PatcherClass } from './../../../patchers/NodePatcher';
import BlockPatcher from './BlockPatcher';
import ClassAssignOpPatcher from './ClassAssignOpPatcher';
import ClassPatcher from './ClassPatcher';
export default class ClassBlockPatcher extends BlockPatcher {
    static patcherClassForChildNode(node: Node, property: string): PatcherClass | null;
    patch(options?: PatchOptions): void;
    shouldAllowInvalidConstructors(): boolean;
    shouldEnableBabelWorkaround(): boolean;
    getClassPatcher(): ClassPatcher;
    canPatchAsExpression(): boolean;
    hasConstructor(): boolean;
    boundInstanceMethods(): Array<ClassAssignOpPatcher>;
}
