import * as React from 'react';

type WelcomeProps = {
    message: string
}

export const Welcome: React.FC<WelcomeProps> = ({ message }) => (
    <button onClick={() => alert(message)}>
      Click on me!
    </button>
)



