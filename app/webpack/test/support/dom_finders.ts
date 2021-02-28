import { fireEvent, screen } from "@testing-library/react";

export const findField = (
  label: string,
  exact: boolean = false
): HTMLInputElement | null => {
  return screen.queryByLabelText(label, { exact }) as HTMLInputElement;
};

export const findButton = (name: string): HTMLButtonElement | null => {
  return screen.queryByRole("button", { name }) as HTMLButtonElement;
};

export const findFieldByPlaceholder = (
  placeholder: string
): HTMLInputElement | null => {
  return screen.queryByPlaceholderText(placeholder) as HTMLInputElement;
};

export const fillIn = (input: HTMLInputElement, value: string) => {
  fireEvent.focus(input);
  fireEvent.change(input, { target: { value } });
  fireEvent.blur(input);
};
