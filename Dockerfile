ARG IMAGE_REF
FROM $IMAGE_REF/tools
LABEL author="seongyong.kim@shiftsecurityleft.io"

RUN mkdir -p /root/bin
ENV PATH=/root/bin:$PATH
COPY ./bin /root/bin
# RUN echo 'export PATH=/root/bin:$PATH' > temp
# RUN echo 'source /root/bin/pipeline-library.sh' >> temp
# RUN echo '[ -f /opt/gitlab/cicd/agent/build/pipeline-override.sh ] && source /opt/gitlab/cicd/agent/build/pipeline-override.sh' >> temp
# RUN mv temp $HOME/.profile
RUN echo 'export PATH=/root/bin:$PATH' > temp
RUN echo 'source /root/bin/pipeline-library.sh' >> temp
RUN echo '[ -f /opt/gitlab/cicd/agent/build/pipeline-override.sh ] && source /opt/gitlab/cicd/agent/build/pipeline-override.sh' >> temp
RUN cat temp >> /root/.profile

# test This is needed so that it will execute .bashrc at the beginning of Gitlab CI scripts
SHELL ["/bin/bash", "-c", "-l"]

WORKDIR /opt/gitlab/cicd/agent/build

ENTRYPOINT /bin/bash
