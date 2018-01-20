import NodePatcher from './NodePatcher';
import { PatcherContext } from './types';
export default class ProgramPatcher extends NodePatcher {
    body: NodePatcher | null;
    helpers: Map<string, string>;
    _indentString: string | null;
    constructor(patcherContext: PatcherContext, body: NodePatcher | null);
    shouldTrimContentRange(): boolean;
    /**
     * Register a helper to be reused in several places.
     *
     * FIXME: Pick a different name than what is in scope.
     */
    registerHelper(name: string, code: string): string;
    patchHelpers(): void;
    /**
     * Gets the indent string used for each indent in this program.
     */
    getProgramIndentString(): string;
}
