/**
 * Determine the variables introduced by this assignee (array destructure,
 * object destructure, rest, etc.).
 */
import { Node } from 'decaffeinate-parser/dist/nodes';
export default function getAssigneeBindings(node: Node): Array<string>;
