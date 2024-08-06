#!/usr/bin/env bash
# remove contianers
docker rm bomberman_container 
# remove images
docker rmi Image bomberman_image:latest
# prune stuff
docker system prune
# docker system prune --all # last resort
