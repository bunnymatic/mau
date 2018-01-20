import NodePatcher from '../patchers/NodePatcher';
/**
 * Find the enclosing node defining the "soak range" for a given soak operation.
 * For example, in the expression `a(b?.c.d())`, returns the `b?.c.d()` node,
 * since that's the chain of operations that will be skipped if `b` is null or
 * undefined.
 */
export default function findSoakContainer(patcher: NodePatcher): NodePatcher;
