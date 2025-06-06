
export const isObject = (maybeObj: any): maybeObj is Object => {
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


type EllipsisOptions = {
    ellipsis:string,
    max: number,
    splitChars: string[],
}

const ELLPISIS_DEFAULTS: EllipsisOptions = {
    ellipsis: "…",
    max: 140,
    splitChars: [" ", "-"],
  };

export const ellipsizeParagraph =  (str: string, options: Partial<EllipsisOptions> = {}): string => {
  var c, i, last, len;
  const { max, splitChars, ellipsis } = { ...ELLPISIS_DEFAULTS, ...options };

  last = 0;
  c = "";
  if (str.length < max) {
    return str;
  }
  i = 0;
  len = str.length;
  while (i < len) {
    c = str.charAt(i);
    i++;
    if (splitChars.indexOf(c) !== -1) {
      last = i;
      if (i < max) {
        continue;
      }
      if (last === 0) {
        return str.substring(0, max - 1) + ellipsis
      }
      return str.substring(0, last) + ellipsis;
    }
  }
  return str;
};