export default class PatchError extends Error {
    readonly message: string;
    readonly source: string;
    readonly start: number;
    readonly end: number;
    constructor(message: string, source: string, start: number, end: number);
    toString(): string;
    /**
     * Due to babel's inability to simulate extending native types, we have our
     * own method for determining whether an object is an instance of
     * `PatchError`.
     *
     * @see http://stackoverflow.com/a/33837088/549363
     */
    static detect(error: Error): boolean;
    static prettyPrint(error: PatchError): string;
}
