/**
 * Determines whether the given node spans multiple lines.
 */
export default function isMultiline(source, node) {
    var newlineIndex = source.indexOf('\n', node.start);
    return newlineIndex >= 0 && newlineIndex < node.end;
}
