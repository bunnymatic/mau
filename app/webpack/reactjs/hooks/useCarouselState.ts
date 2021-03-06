import { isEmpty, noop } from "@js/app/helpers";
import { Dispatch, SetStateAction, useState } from "react";

interface CarouselStateReturn<T> {
  current: T;
  next: () => T;
  previous: () => T;
  setCurrent: Dispatch<SetStateAction<T>>;
}

export const useCarouselState = <T>(
  items: T[],
  initial?: T
): CarouselStateReturn<T> => {
  if (isEmpty(items)) {
    return {
      current: initial,
      next: noop,
      previous: noop,
      setCurrent: noop,
    };
  }

  const [current, setCurrent] = useState<T>(
    initial ?? (items.length ? items[0] : undefined)
  );
  const numItems = items.length;

  const next = () => {
    const currentIndex = items.findIndex((val) => val === current);
    const index: number = (currentIndex + 1) % numItems;
    const newCurrent = items[index];
    setCurrent(newCurrent);
    return newCurrent;
  };

  const previous = () => {
    const currentIndex = items.findIndex((val) => val === current);
    let index = currentIndex;
    if (currentIndex <= 0) {
      index = items.length;
    }
    index = index - 1;
    const newCurrent = items[index];
    setCurrent(newCurrent);
    return newCurrent;
  };

  return {
    current,
    next,
    previous,
    setCurrent,
  };
};
