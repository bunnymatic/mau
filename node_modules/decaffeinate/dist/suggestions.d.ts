export declare type Suggestion = {
    suggestionCode: string;
    message: string;
};
export declare const REMOVE_BABEL_WORKAROUND: {
    suggestionCode: string;
    message: string;
};
export declare const REMOVE_ARRAY_FROM: {
    suggestionCode: string;
    message: string;
};
export declare const CLEAN_UP_IMPLICIT_RETURNS: {
    suggestionCode: string;
    message: string;
};
export declare const REMOVE_GUARD: {
    suggestionCode: string;
    message: string;
};
export declare const AVOID_INLINE_ASSIGNMENTS: {
    suggestionCode: string;
    message: string;
};
export declare const SIMPLIFY_COMPLEX_ASSIGNMENTS: {
    suggestionCode: string;
    message: string;
};
export declare const SIMPLIFY_DYNAMIC_RANGE_LOOPS: {
    suggestionCode: string;
    message: string;
};
export declare const CLEAN_UP_FOR_OWN_LOOPS: {
    suggestionCode: string;
    message: string;
};
export declare const FIX_INCLUDES_EVALUATION_ORDER: {
    suggestionCode: string;
    message: string;
};
export declare const AVOID_IIFES: {
    suggestionCode: string;
    message: string;
};
export declare const AVOID_INITCLASS: {
    suggestionCode: string;
    message: string;
};
export declare const SHORTEN_NULL_CHECKS: {
    suggestionCode: string;
    message: string;
};
export declare const AVOID_TOP_LEVEL_THIS: {
    suggestionCode: string;
    message: string;
};
export declare const AVOID_TOP_LEVEL_RETURN: {
    suggestionCode: string;
    message: string;
};
export declare function mergeSuggestions(suggestions: Array<Suggestion>): Array<Suggestion>;
export declare function prependSuggestionComment(code: string, suggestions: Array<Suggestion>): string;
