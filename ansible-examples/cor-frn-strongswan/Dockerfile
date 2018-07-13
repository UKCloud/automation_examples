FROM python:2.7
 
ENV ANSIBLE_VERSION 2.5.0
 

RUN set -x && \
  pip install --upgrade pip && \
  pip install ansible==${ANSIBLE_VERSION} python-openstackclient shade && \
  echo "Done"
 
ENV ANSIBLE_GATHERING smart
ENV ANSIBLE_HOST_KEY_CHECKING false
ENV ANSIBLE_RETRY_FILES_ENABLED false
ENV ANSIBLE_ROLES_PATH /ansible/playbooks/roles
# ENV ANSIBLE_SSH_PIPELINING True
ENV PYTHONPATH /ansible/lib
ENV PATH /ansible/bin:$PATH
ENV ANSIBLE_LIBRARY /ansible/library
 
WORKDIR /ansible/playbooks
 
ENTRYPOINT ["bash"]
