import SourceMap, { V3SourceMap } from './sourcemap';
import { Token, LexerOptions } from './lexer';
import { Block } from './nodes';

export const VERSION: string;
export const FILE_EXTENSIONS: Array<string>;

interface CompileOptions {
  bare?: boolean;
  header?: boolean;
  shiftLine?: boolean;

  // Source map options.
  sourceMap?: boolean;
  generatedFile?: string;
  sourceRoot?: string;
  sourceFiles?: Array<string>;
  inline?: boolean;
}

type CompileResult = string | {
  js: string,
  sourceMap: SourceMap,
  v3SourceMap: V3SourceMap,
};

interface RunOptions extends CompileOptions {
  filename?: string;
}

/**
 * Compile CoffeeScript code to JavaScript, using the Coffee/Jison compiler.
 *
 * If `options.sourceMap` is specified, then `options.filename` must also be specified.  All
 * options that can be passed to `SourceMap#generate` may also be passed here.
 *
 * This returns a javascript string, unless `options.sourceMap` is passed,
 * in which case this returns a `{js, v3SourceMap, sourceMap}`
 * object, where sourceMap is a sourcemap.coffee#SourceMap object, handy for doing programatic
 * lookups.
 */
export function compile(code: string, options?: CompileOptions): string | CompileResult;

/**
 * Tokenize a string of CoffeeScript code, and return the array of tokens.
 */
export function tokens(code: string, options?: LexerOptions): Array<Token>;

/**
 * Parse a string of CoffeeScript code or an array of lexed tokens, and
 * return the AST. You can then compile it by calling `.compile()` on the root,
 * or traverse it by using `.traverseChildren()` with a callback.
 */
export function nodes(source: string | Array<Token>, options?: LexerOptions): Block;

/**
 * Compile and execute a string of CoffeeScript (on the server), correctly
 * setting `__filename`, `__dirname`, and relative `require()`.
 */
export function run(code: string, options?: RunOptions): void;
