import * as React from 'react';

interface WelcomeProps {
  message: string
}

export const Welcome: React.FC<WelcomeProps> = ({ message }) => (
    <button onClick={() => alert(message)}>
      Click on me!
    </button>
)
