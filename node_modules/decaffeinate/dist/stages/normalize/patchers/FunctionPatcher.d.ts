import { PatcherContext } from '../../../patchers/types';
import NodePatcher from './../../../patchers/NodePatcher';
import BlockPatcher from './BlockPatcher';
export default class FunctionPatcher extends NodePatcher {
    parameters: Array<NodePatcher>;
    body: BlockPatcher | null;
    constructor(patcherContext: PatcherContext, parameters: Array<NodePatcher>, body: BlockPatcher | null);
    patchAsExpression(): void;
    /**
     * Produce assignments to put at the top of the function for this parameter.
     * Also declare any variables that are assigned and need to be
     * function-scoped, so the outer code can insert `var` declarations.
     */
    patchParameterAndGetAssignments(parameter: NodePatcher): {
        newAssignments: Array<string>;
        newBindings: Array<string>;
    };
    /**
     * If the assignee in a generated code is multiline and we're not careful, we
     * might end up placing code before the function body indentation level, which
     * will make the CoffeeScript parser complain later. To fix, adjust the
     * indentation to the desired level. Note that this potentially could add
     * whitespace to multiline strings, but all types of multiline strings in
     * CoffeeScript strip common leading whitespace, so the resulting code is
     * still the same.
     */
    fixGeneratedAssigneeWhitespace(assigneeCode: string): string;
    /**
     * Get the index of the first parameter that will be included in the rest
     * parameters (if any). All parameters from this point forward will be moved
     * to an array destructure at the start of the function.
     *
     * The main stage handles the fully general case for array destructuring,
     * including things like nested expansions and defaults, so anything requiring
     * that level of generality should be extracted to an array destructure.
     * Simpler cases that only use param defaults and this-assignment are better
     * off being handled as normal parameters if we can get away with it. Also,
     * any array destructure in a parameter needs to be extracted so that we can
     * properly wrap it in Array.from.
     */
    getFirstRestParamIndex(): number;
}
