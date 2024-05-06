import Flash from "@js/app/flash";
import {
  AddEmailModal,
  OnAddCallback,
} from "@reactjs/components/admin/add_email_modal";
import { MauTextButton } from "@reactjs/components/mau_text_button";
import * as types from "@reactjs/types";
import { api } from "@services/api";
import React, { FC, useCallback, useEffect, useState } from "react";

interface EmailItem {
  id: types.IdType;
  email: string;
  name?: string;
  createdAt: string;
  updatedAt: string;
}

interface EmailListItemProps {
  name?: string;
  email: string;
  id: types.IdType;
  handleDelete: (id) => void;
}

const EmailListItemLabel: FC<{ email: string; name?: string }> = ({
  email,
  name,
}) => {
  if (name) {
    return (
      <>
        <span>{name}</span> <span>&lt;{email}&gt;</span>
      </>
    );
  } else {
    return <span>&lt;{email}&gt;</span>;
  }
};

const EmailListItem: FC<EmailListItemProps> = ({
  id,
  email,
  name,
  handleDelete,
}) => {
  const title = `remove ${email} from the list`;
  const onClick = (_ev) => handleDelete(id);

  return (
    <div className="email-list-item__wrapper">
      <div className="email-list-item">
        <EmailListItemLabel email={email} name={name} />
      </div>
      <div className="email-list-item__del-btn">
        <MauTextButton onClick={onClick} title={title}>
          <i className="fa fa-times"></i>
        </MauTextButton>
      </div>
    </div>
  );
};

interface EmailListProps {
  emails: EmailItem[];
  handleDelete: (id) => void;
}

const EmailList: FC<EmailListProps> = ({ emails, handleDelete }) => {
  return emails.map((email) => (
    <EmailListItem {...email} key={email.id} handleDelete={handleDelete} />
  ));
};

export interface EmailListManagerProps {
  title: string;
  info: string;
  listId: types.IdType;
}

export const EmailListManager: FC<EmailListManagerProps> = ({
  info,
  title,
  listId,
}) => {
  const [emails, setEmails] = useState<EmailItem[]>([]);

  const fetchEmails = useCallback(() => {
    api.emailLists.emails
      .index(listId)
      .then(({ emails }) => {
        setEmails(emails.map(({ email }) => email));
      })
      .catch((_err) => {
        new Flash().show({ error: "Ack. Something went awry." });
      });
  }, [listId]);

  const handleDelete = (id) => {
    return api.emailLists.emails.remove(id, listId).then(fetchEmails);
  };

  const onAdd: OnAddCallback = (_added) => {
    fetchEmails();
  };

  useEffect(() => {
    fetchEmails();
  }, [fetchEmails]);

  return (
    <div className="email-list-manager__wrapper">
      <h4 className="email-list-manager__header">
        {title}
        <AddEmailModal onAdd={onAdd} listId={listId} />
      </h4>
      <div className="email-list-manager__help">{info}</div>
      {Boolean(emails.length) && (
        <EmailList emails={emails} handleDelete={handleDelete} />
      )}
    </div>
  );
};
