/**
 * Inserts string escape characters before certain characters/strings to be
 * escaped.
 *
 * The skipPattern parameter describes which already-escaped characters to skip
 * over. For normal strings, if we see any backslash, we skip it and the next
 * character, but for heregexes, we only skip a backslash followed by
 * whitespace.
 */
export default function escape(source, patcher, skipPattern, escapeStrings, start, end) {
    var _loop_1 = function (i) {
        if (skipPattern.test(source.slice(i, end))) {
            i++;
        }
        else if (escapeStrings.some(function (str) { return source.slice(i, i + str.length) === str; })) {
            patcher.appendRight(i, '\\');
        }
        out_i_1 = i;
    };
    var out_i_1;
    for (var i = start; i < end; i++) {
        _loop_1(i);
        i = out_i_1;
    }
}
