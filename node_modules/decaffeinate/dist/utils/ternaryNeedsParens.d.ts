import NodePatcher from '../patchers/NodePatcher';
/**
 * Given a main stage patcher, determine from the AST if it needs to be wrapped
 * in parens when transformed into a JS ternary.
 *
 * Be defensive by listing all known common cases where this is correct, and
 * requiring parens in all other cases. That way, any missed cases result in
 * slightly ugly code rather than incorrect code.
 */
export default function ternaryNeedsParens(patcher: NodePatcher): boolean;
