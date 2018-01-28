import PatchError from './PatchError';
/**
 * If the given exception is an error with code location information, extract
 * its start and end position and return a PatchError to use in its place.
 * Otherwise, return null.
 */
export default function resolveToPatchError(err: any, content: string, stageName: string): PatchError | null;
