import React, {FC} from 'react'

interface ReactTestComponentProps {};

import { FavoriteThis } from "./favorite_this";

export const ReactTestComponent:FC<ReactTestComponentProps> = (props) => {
  return <div>
    <FavoriteThis type="Artist" id={10}/>
    <FavoriteThis type="whatever" id={310}/>
  </div>;
}
