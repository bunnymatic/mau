import * as React from "react";
import {Welcome} from "./hello_react";

interface AppProps {
    message: string
}

export const App: React.FC<AppProps> = ({ message }) => (
    <Welcome message={message} />
)
