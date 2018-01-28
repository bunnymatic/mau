import NodePatcher from '../patchers/NodePatcher';
/**
 * Determine if this is a block has an object initializer as its leftmost node.
 * That means that in its JS form, the expression will start with a `{`
 * character and need to be wrapped in parens when used in a JS arrow function.
 */
export default function blockStartsWithObjectInitialiser(patcher: NodePatcher): boolean;
