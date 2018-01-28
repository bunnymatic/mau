import SourceToken from 'coffee-lex/dist/SourceToken';
import SharedProgramPatcher from '../../../patchers/SharedProgramPatcher';
export default class ProgramPatcher extends SharedProgramPatcher {
    canPatchAsExpression(): boolean;
    patchAsStatement(): void;
    /**
     * Removes continuation tokens (i.e. '\' at the end of a line).
     *
     * @private
     */
    patchContinuations(): void;
    /**
     * Replaces CoffeeScript style comments with JavaScript style comments.
     *
     * @private
     */
    patchComments(): void;
    /**
     * Patches a block comment.
     *
     * @private
     */
    patchBlockComment(comment: SourceToken): void;
    /**
     * Patches a single-line comment.
     *
     * @private
     */
    patchLineComment(comment: SourceToken): void;
    /**
     * Patches a shebang comment.
     *
     * @private
     */
    patchShebangComment(comment: SourceToken): void;
    /**
     * Serve as the implicit return patcher for anyone not included in a function.
     */
    canHandleImplicitReturn(): boolean;
}
