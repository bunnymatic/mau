import determineIndent from './determineIndent';
import getIndent from './getIndent';
/**
 * Adjust an indent in source at a specific offset by an amount.
 */
export default function adjustIndent(source, offset, adjustment) {
    var currentIndent = getIndent(source, offset);
    var determinedIndent = determineIndent(source);
    if (adjustment > 0) {
        while (adjustment--) {
            currentIndent += determinedIndent;
        }
    }
    else if (adjustment < 0) {
        currentIndent = currentIndent.slice(determinedIndent.length * -adjustment);
    }
    return currentIndent;
}
