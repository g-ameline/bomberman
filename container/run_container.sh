#!/usr/bin/env bash
# │├ ─ ┘└ 
echo " building bomberman server"
docker image build  --progress=plain   --no-cache   --file ./Dockerfile   --tag bomberman_image:latest ../ 
#        log progress ┘ clean uild every time ┘         │                  └ name the image             │
#                               specify dockerfile path ┘                       root for the dockerfile ┘
echo " running containerized app server"
docker container run  \
  --publish 1111:1111  --publish 3333:3333  --publish 5555:5555  --publish 7777:7777  \
  --name bomberman_container \
  --rm  \
   bomberman_image # image to use

# docker \
#   image build \ # sd
#   --progress=plain \ # show evolution in terminal
#   --no-cache \ # force clean build (for debigging/dev)
#   --file ../../docker/app_server/Dockerfile \ # specify filepath to dockerfile
#   --tag bomberman_image:1 \ # specify name of the image
#   . # root used by the dockerfile


# docker container run \
#   # --detach \ # if log or ineraction not needed
#   --publish 1111:1111 \ # publish ports page_server container'sport:host's port  
#   --publish 3333:3333 \ # publish ports chat_server container'sport:host's port  
#   --publish 5555:5555 \ # publish ports  container'sport:host's port  
#   --publish 7777:7777 \ # publish ports  container'sport:host's port  
#   --rm \ # clean everything when done
#   --name bomberman_container \ # secify name of the container
#   bomberman_image # image to use


