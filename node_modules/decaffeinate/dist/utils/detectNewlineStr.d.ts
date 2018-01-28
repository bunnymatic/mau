/**
 * Determine the most common newline string in the given code, either '\n' or
 * '\r\n'. Prefer '\n' in the case of a tie.
 */
export default function detectNewlineStr(source: string): string;
