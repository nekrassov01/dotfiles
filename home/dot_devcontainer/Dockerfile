FROM ubuntu:22.04

ARG USERNAME=dev-user
ARG SUDOER_FILE=/etc/sudoers.d/${USERNAME}

RUN apt -y update && apt -y upgrade && apt -y install sudo \
&& useradd -m -d /home/${USERNAME} -s /bin/bash ${USERNAME} \
&& touch ${SUDOER_FILE} && echo "${USERNAME} ALL=NOPASSWD: ALL" >${SUDOER_FILE}
