export const isObject = (maybeObj: unknown): maybeObj is object => {
  return (
    (typeof maybeObj === "object" || typeof maybeObj === "function") &&
    maybeObj !== null &&
    !Array.isArray(maybeObj)
  );
};

export const isNil = <T>(val?: T | null): val is null | undefined =>
  val === null || isUndefined(val);

export const isUndefined = <T>(val: T | undefined): val is undefined =>
  val === undefined;

export const isString = (data: unknown): data is string => {
  return typeof data === "string";
};

type EllipsisOptions = {
  ellipsis: string;
  max: number;
  splitChars: string[];
};

const ELLPISIS_DEFAULTS: EllipsisOptions = {
  ellipsis: "…",
  max: 140,
  splitChars: [" ", "-"],
};

export const ellipsizeParagraph = (
  str: string,
  options: Partial<EllipsisOptions> = {}
): string => {
  let c, i, last;
  const { max, splitChars, ellipsis } = { ...ELLPISIS_DEFAULTS, ...options };
  const len = str.length;

  last = 0;
  c = "";
  if (len < max) {
    return str;
  }
  i = 0;
  while (i < len) {
    c = str.charAt(i);
    i++;
    if (splitChars.indexOf(c) !== -1) {
      last = i;
      if (i < max) {
        continue;
      }
      if (last === 0) {
        return str.substring(0, max - 1) + ellipsis;
      }
      return str.substring(0, last) + ellipsis;
    }
  }
  return str;
};
