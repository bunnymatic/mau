export const randomBoolean = (): Boolean => Math.random() > 0.5;
export const randomInt = (max: number, min: number = 0): number => {
  return Math.floor(Math.random() * Math.floor(max - min)) + min;
};
