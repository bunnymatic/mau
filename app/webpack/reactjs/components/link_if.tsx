import React, { FC } from "react";

interface LinkIfProps {
  href?: string;
  label: string;
}

export const LinkIf: FC<LinkIfProps> = ({ href, label }) => {
  if (href) {
    return (
      <a className="link-if" href={href} title={label}>
        {label}
      </a>
    );
  } else {
    return <span className="link-if">{label}</span>;
  }
};
