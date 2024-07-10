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
