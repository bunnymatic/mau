import { Suggestion } from './suggestions';
import PatchError from './utils/PatchError';
export { default as run } from './cli';
import { Options } from './options';
export { PatchError };
export declare type ConversionResult = {
    code: string;
};
export declare type StageResult = {
    code: string;
    suggestions: Array<Suggestion>;
};
/**
 * Convert CoffeeScript source code into modern JavaScript preserving comments
 * and formatting.
 */
export declare function convert(source: string, options?: Options): ConversionResult;
export declare function modernizeJS(source: string, options?: Options): ConversionResult;
