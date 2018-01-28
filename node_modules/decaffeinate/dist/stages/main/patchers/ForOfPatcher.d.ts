import { ForOf } from 'decaffeinate-parser/dist/nodes';
import NodePatcher from '../../../patchers/NodePatcher';
import ForPatcher from './ForPatcher';
export default class ForOfPatcher extends ForPatcher {
    node: ForOf;
    keyAssignee: NodePatcher;
    patchAsStatement(): void;
    removeOwnTokenIfExists(): void;
    requiresExtractingTarget(): boolean;
    targetBindingCandidate(): string;
    indexBindingCandidates(): Array<string>;
    willPatchAsIIFE(): boolean;
}
