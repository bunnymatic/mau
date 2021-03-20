import { mailToLink } from "@js/services/mailer.service";
import React, { FC } from "react";

type MailerProps = {
  domain?: string;
  name?: string;
  subject?: string;
  external?: boolean;
  text: string;
};

export const Mailer: FC<MailerProps> = ({ subject, name, domain, text, external}) => {
  const setLocation: void = (_ev) => {
    window.location.assign(mailToLink(subject, name, domain, external));
  };
  return (
    <a className="mailer-link" onClick={setLocation}>
      {text}
    </a>
  );
};
