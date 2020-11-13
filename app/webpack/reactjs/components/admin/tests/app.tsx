import * as React from "react";
import {Welcome} from "./welcome";

interface AppProps {
    message: string
}

export const App: React.FC<AppProps> = ({ message }) => (
    <Welcome message={message} />
)
