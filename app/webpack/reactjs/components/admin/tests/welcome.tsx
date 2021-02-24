import React, { FC } from "react";

interface WelcomeProps {
  message: string;
}

export const Welcome: FC<WelcomeProps> = ({ message }) => (
  <button onClick={() => alert(message)}>Click on me!</button>
);
