import NodePatcher from '../patchers/NodePatcher';
export declare type PrototypeAssignPatchers = {
    classRefPatcher: NodePatcher;
    methodAccessPatcher: NodePatcher;
};
/**
 * Given a main stage patcher, determine if it assigns a function to a class
 * prototype. This means that a super call within the function needs access to
 * the enclosing function.
 */
export default function extractPrototypeAssignPatchers(patcher: NodePatcher): PrototypeAssignPatchers | null;
