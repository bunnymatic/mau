import { render } from "@testing-library/react";
import { Formik } from "formik";
import React, { ReactElement } from "react";
import { vi } from "vitest";
export interface ServicesRenderResult {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  history?: any;
}

interface RenderInFormConfig {
  onSubmit: () => void;
  initialValues: Record<string, unknown>;
}

export const defaultConfig: RenderInFormConfig = {
  onSubmit: vi.fn(),
  initialValues: {},
};

export const renderInForm = (
  component: ReactElement,
  config: RenderInFormConfig = defaultConfig
) => {
  const rendered = render(<Formik {...config}>{component}</Formik>);
  return rendered;
};
