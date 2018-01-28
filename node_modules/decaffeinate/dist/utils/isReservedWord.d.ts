/**
 * Determine if the given string is a reserved word in either CoffeeScript or
 * JavaScript, useful to avoid generating variables with these names. Sometimes
 * we generate CoffeeScript and sometimes JavaScript, so just avoid names that
 * are reserved in either language.
 */
export default function isReservedWord(name: string): boolean;
/**
 * Determine if the given name should not be used as a JavaScript variable,
 * conforming to CoffeeScript's equivalent implementation.
 */
export declare function isForbiddenJsName(name: string): boolean;
