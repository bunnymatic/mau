import { Node } from 'decaffeinate-parser/dist/nodes';
import { PatcherClass } from '../../patchers/NodePatcher';
import TransformCoffeeScriptStage from '../TransformCoffeeScriptStage';
export default class MainStage extends TransformCoffeeScriptStage {
    patcherConstructorForNode(node: Node): PatcherClass | null;
}
