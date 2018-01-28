var detectIndent = require('detect-indent');
var DEFAULT_INDENT = '  ';
export default function determineIndent(source) {
    var indent = detectIndent(source);
    if (indent.type === 'space' && indent.amount % 2 === 1) {
        return DEFAULT_INDENT;
    }
    return indent.indent || DEFAULT_INDENT;
}
