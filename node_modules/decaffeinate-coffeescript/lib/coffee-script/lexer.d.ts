import { LocationData } from './nodes';

export type TokenType =
  'BIN?' |
  'BOOL' |
  'CALL_END' |
  'CALL_START' |
  'COMPARE' |
  'COMPOUND_ASSIGN' |
  'COMPOUND_ASSIGN' |
  'FOR' |
  'FORINSTANCEOF' |
  'FUNC_EXIST' |
  'HERESTRING' |
  'IDENTIFIER' |
  'IF' |
  'INDENT' |
  'INDEX_END' |
  'INDEX_SOAK' |
  'INDEX_START' |
  'INSTANCEOF' |
  'LEADING_WHEN' |
  'MATH' |
  'NEOSTRING' |
  'OUTDENT' |
  'OUTDENT' |
  'OWN' |
  'PARAM_END' |
  'PARAM_START' |
  'REGEX' |
  'REGEX_END' |
  'REGEX_START' |
  'RELATION' |
  'SHIFT' |
  'STATEMENT' |
  'STRING' |
  'STRING_END' |
  'STRING_START' |
  'TERMINATOR' |
  'TOKENS' |
  'UNARY' |
  'UNARY_MATH' |
  'UNLESS' |
  'WHEN' |
  'YIELD';

export type Token = [
  TokenType,
  // code
  string,
  LocationData
];

export interface LexerOptions {
  literate?: boolean;
  line?: number;
  column?: number;
  untilBalanced?: boolean;
  rewrite?: boolean;
}

export class Lexer {
  /**
   * **tokenize** is the Lexer's main method. Scan by attempting to match tokens
   * one at a time, using a regular expression anchored at the start of the
   * remaining code, or a custom recursive token-matching method
   * (for interpolations). When the next token has been recorded, we move forward
   * within the code past the token, and begin again.
   *
   * Each tokenizing method is responsible for returning the number of characters
   * it has consumed.
   *
   * Before returning the token stream, run it through the [Rewriter](rewriter.html).
   */
  tokenize(code: string, opts?: LexerOptions): Array<Token>;

  /**
   * Preprocess the code to remove leading and trailing whitespace, carriage
   * returns, etc. If we're lexing literate CoffeeScript, strip external Markdown
   * by removing all lines that aren't indented by at least four spaces or a tab.
   */
  clean(code: string): string;
}
