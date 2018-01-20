export default class SourceMap {
  sourceLocation(arg: [number, number]): [number, number] | null;
}

export interface V3SourceMap {
  version: 3;
  file: string;
  sourceRoot: string;
  sources: Array<string>;
  sourcesContent: Array<string | null>;
  names: Array<string>;
  mappings: string;
}
