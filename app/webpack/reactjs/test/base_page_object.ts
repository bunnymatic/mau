import { fireEvent, screen } from "@testing-library/react";

export interface BasePageObjectProps {
  debug?: boolean;
  raiseOnFind?: boolean;
}
export class BasePageObject {
  private readonly debug: boolean;
  private readonly raiseOnFind: boolean;

  constructor(
    { debug, raiseOnFind }: BasePageObjectProps = {
      debug: false,
      raiseOnFind: false,
    }
  ) {
    this.debug = Boolean(debug);
    this.raiseOnFind = Boolean(raiseOnFind);
  }

  findButtons(name: string): HTMLButtonElement[] {
    this.debugLog(`trying to find a button with text "${name}"`);
    return screen.getAllByRole("button", { name }) as HTMLButtonElement[];
  }

  findButton(name: string, opts: { exact?: boolean } = {}): HTMLButtonElement {
    this.debugLog(`trying to find a button with text "${name}"`);
    return screen.getByRole("button", { name, ...opts }) as HTMLButtonElement;
  }

  clickButton(button: HTMLButtonElement) {
    fireEvent.click(button);
  }

  clickElement(element: HTMLInputElement | HTMLElement) {
    fireEvent.click(element);
  }

  find(
    txt: string,
    opts: { exact?: boolean; getBy?: "Role" | "Text" } = {}
  ): HTMLElement | undefined {
    this.debugLog(`trying to find "${txt}"`);
    try {
      return screen[
        `getBy${opts?.getBy ?? "Text"}` as "getByText" | "getByRole"
      ](txt, opts);
    } catch (ex) {
      if (this.raiseOnFind) {
        throw ex;
      }
    }
  }

  findAll(txt: string, opts: { exact?: boolean } = {}): HTMLElement[] {
    this.debugLog(`trying to findAll "${txt}"`);
    return screen.getAllByText(txt, opts) as HTMLElement[];
  }

  findInput(label: string): HTMLInputElement {
    return screen.getByLabelText(label) as HTMLInputElement;
  }

  fillInInput(input: HTMLElement, value: string) {
    fireEvent.focus(input);
    fireEvent.change(input, { target: { value } });
    fireEvent.blur(input);
  }

  selectOption(selectField: HTMLElement, value: string) {
    fireEvent.focus(selectField);
    fireEvent.change(selectField, {
      target: { value },
    });
  }

  private debugLog(msg: string) {
    if (this.debug) {
      // eslint-disable-next-line no-console
      console.debug(msg);
    }
  }
}
