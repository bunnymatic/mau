export const identity = (x) => x;
export function isFunction(func) {
  return Boolean(func && typeof func === "function");
}
export function each(data, cb) {
  if (Array.isArray(data)) {
    data.forEach(cb);
  } else {
    Object.entries(data).forEach(([key, value], _idx) => {
      cb(value, key, data);
    });
  }
}
export function groupBy(arr, keyOrCb) {
  let cb = keyOrCb;
  if (!isFunction(keyOrCb)) {
    cb = (v) => v[keyOrCb];
  }
  return arr.reduce((memo, item) => {
    memo[cb(item)] = memo[cb(item)] || [];
    memo[cb(item)].push(item);
    return memo;
  }, {});
}

export function map(data, cb) {
  if (Array.isArray(data)) {
    return data.reduce((memo, item) => {
      memo.push(cb(item));
      return memo;
    }, []);
  }
  return Object.entries(data).reduce((memo, [val, key]) => {
    memo.push(cb(key, val));
    return memo;
  }, []);
}

export function uniq(arr) {
  return [...new Set(arr)];
}

export function sortBy(arr, key) {
  const sorter = (key) => {
    return (a, b) => (a[key] > b[key] ? 1 : b[key] > a[key] ? -1 : 0);
  };
  return [...arr].sort(sorter(key));
}

export function some(arr, comparator = identity) {
  if (!arr) {
    return false;
  }
  const len = arr.length;
  let ii = 0;
  for (; ii < len; ++ii) {
    const v = arr[ii];
    if (comparator(v)) {
      return true;
    }
  }
  return false;
}

export function omit(obj, keysToOmit) {
  let keys = keysToOmit;
  if (!Array.isArray(keys)) {
    keys = [keys];
  }
  return Object.keys(obj).reduce((memo, key) => {
    if (!keys.includes(key)) {
      memo[key] = obj[key];
    }
    return memo;
  }, {});
}

export function intersection(arr1, arr2) {
  const set2 = new Set(arr2);
  return [...arr1.filter((x) => set2.has(x))];
}

export function pluck_function(field) {
  return (data) => data[field];
}