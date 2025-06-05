import { routing } from "@js/services/routing.service";
import * as types from "@reactjs/types";
import React, { type ReactNode } from "react";

type EditableContentTriggerProps = types.CmsDocument;

export const EditableContentTrigger = ({
  cmsid,
  page,
  section,
}: EditableContentTriggerProps): ReactNode => {
  const path = cmsid
    ? routing.editCmsDocumentPath({ id: cmsid })
    : routing.newCmsDocumentPath({ page, section });
  return (
    <a className="editable-content-trigger" href={path} target="_blank">
      edit me
    </a>
  );
};
