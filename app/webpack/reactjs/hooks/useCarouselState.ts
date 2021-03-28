import { isEmpty, noop } from "@js/app/helpers";
import { useState } from "react";

export const useCarouselState = (items: [], initial?) => {
  if (isEmpty(items)) {
    return {
      current: initial,
      next: noop,
      previous: noop,
    };
  }

  const [current, setCurrent] = useState(initial ?? items[0]);
  const numItems = items.length;

  const next = () => {
    const currentIndex = items.findIndex((val) => val === current);
    const index: number = (currentIndex + 1) % numItems;
    setCurrent(items[index]);
  };

  const previous = () => {
    const currentIndex = items.findIndex((val) => val === current);
    let index = currentIndex;
    if (currentIndex <= 0) {
      index = items.length;
    }
    index = index - 1;
    setCurrent(items[index]);
  };

  return {
    current,
    next,
    previous,
  };
};
