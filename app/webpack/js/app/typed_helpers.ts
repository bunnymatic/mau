const identity = <T>(x: T) => x;

const choose = <T>(arr: T[]) => {
  const len = arr.length;
  const idx = Math.floor(Math.random() * len);
  return arr[idx];
};

const isNil = <T>(val?: T | null): boolean => val === null || isUndefined(val);

const isUndefined = <T>(val: T | undefined): val is undefined =>
  val === undefined;

const stripLines = (msg: string): string => {
  return msg
    .split("\n")
    .map((line) => line.trim())
    .join("\n");
};

const some = <T>(
  arr: T[],
  comparator: (val: T) => T | boolean | null | undefined = identity<T>,
) => {
  if (!arr) {
    return false;
  }
  return arr.some(comparator);
};

export { choose, identity, isNil, isUndefined, some, stripLines };
