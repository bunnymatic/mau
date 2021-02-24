export const formatAsCurrency = (val: number): string => {
  let num = val.toFixed(2);
  if (parseFloat(num) === parseFloat(val.toFixed(0))) {
    num = val.toFixed(0);
  }
  return `$${num.toLocaleString()}`;
};
