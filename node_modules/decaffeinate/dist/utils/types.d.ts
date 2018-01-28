import SourceToken from 'coffee-lex/dist/SourceToken';
import { Node } from 'decaffeinate-parser/dist/nodes';
/**
 * Determines whether a node represents a function, i.e. `->` or `=>`.
 */
export declare function isFunction(node: Node, allowBound?: boolean): boolean;
/**
 * This isn't a great name because newlines do have semantic meaning in
 * CoffeeScript, but it's close enough.
 */
export declare function isSemanticToken(token: SourceToken): boolean;
