import { routing } from "@js/services/routing.service";
import * as types from "@reactjs/types";
import React, { FC } from "react";

interface EditableContentTriggerProps extends types.CmsDocument {}

export const EditableContentTrigger: FC<EditableContentTriggerProps> = ({
  cmsid,
  page,
  section,
}) => {
  const path = cmsid
    ? routing.editCmsDocumentPath({ id: cmsid })
    : routing.newCmsDocumentPath({ page, section });
  return (
    <a className="editable-content-trigger" href={path} target="_blank">
      edit me
    </a>
  );
};
