import { Node } from 'decaffeinate-parser/dist/nodes';
import MagicString from 'magic-string';
import { StageResult } from '../index';
import { Options } from '../options';
import NodePatcher, { PatcherClass } from '../patchers/NodePatcher';
import { Suggestion } from '../suggestions';
import DecaffeinateContext from '../utils/DecaffeinateContext';
export declare type ChildType = NodePatcher | Array<NodePatcher | null> | null;
export default class TransformCoffeeScriptStage {
    readonly ast: Node;
    readonly context: DecaffeinateContext;
    readonly editor: MagicString;
    readonly options: Options;
    static run(content: string, options: Options): StageResult;
    root: NodePatcher | null;
    patchers: Array<NodePatcher>;
    suggestions: Array<Suggestion>;
    constructor(ast: Node, context: DecaffeinateContext, editor: MagicString, options: Options);
    /**
     * This should be overridden in subclasses.
     */
    patcherConstructorForNode(_node: Node): PatcherClass | null;
    build(): NodePatcher;
    patcherForNode(node: Node, parent?: PatcherClass | null, property?: string | null): NodePatcher;
    associateParent(parent: NodePatcher, child: Array<ChildType> | NodePatcher | null): void;
    _patcherConstructorForNode(node: Node): PatcherClass;
}
