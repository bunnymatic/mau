script/destroy scaffold ArtPiece

#generate new schema
script/generate scaffold ArtPiece \
filename:string \
title:string \
description:text \
medium:string \
dimensions:string


#./script/generate authenticated artist sessions —include-activation —stateful —rspec —skip-migration —skip-routes —old-passwords

#rake db:drop && rake db:create && rake db:migrate

