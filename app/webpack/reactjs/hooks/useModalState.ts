import { useState } from "react";

type ModalStateType = "open" | "closed";

export const useModalState = (initialState: ModalStateType = "closed") => {
  const [isOpen, setIsOpen] = useState<boolean>(initialState == "open");
  const open = () => setIsOpen(true);
  const close = () => setIsOpen(false);
  const toggle = () => setIsOpen(!isOpen);
  return {
    isOpen,
    open,
    close,
    toggle,
  };
};
