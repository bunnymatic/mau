import { mailToLink } from "@services/mailer.service";
import React, { FC } from "react";

type MailerProps = {
  domain?: string;
  name?: string;
  subject?: string;
  text: string;
};

export const Mailer: FC<MailerProps> = ({ subject, name, domain, text }) => {
  const setLocation = (_ev) => {
    window.location.assign(mailToLink(subject, name, domain));
  };
  return (
    <a className="mailer-link" onClick={setLocation}>
      {text}
    </a>
  );
};
