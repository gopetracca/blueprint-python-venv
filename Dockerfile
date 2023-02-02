# General arguments
ARG PYTHON_VERSION=3.9.6

############################### stage ###############################
# Python base
FROM python:${PYTHON_VERSION}-slim-buster AS python-base

ARG USERNAME=user
ARG USER_UID=1000
ARG USER_GID=1000

ENV USERNAME=${USERNAME} \
  USER_UID=${USER_UID} \
  USER_GID=${USER_GID}

# Create user
RUN groupadd --gid ${USER_GID} ${USERNAME} \
  && useradd -s /bin/bash --uid ${USER_UID} --gid ${USER_GID} -m ${USERNAME}

# Install packages
RUN apt-get update \
  && apt-get install --no-install-recommends -y \
  make \
  && rm -rf /var/lib/apt/lists/*


############################### stage ###############################
# This stage is to be used when running the app in production
FROM python-base AS prod

COPY ./requirements.txt requirements.txt
RUN pip install -r requirements.txt

COPY ./.docker/docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

ENV PYTHONPATH="${PYTHONPATH}:/app"
WORKDIR /app

# Copy source into the container
COPY . .
RUN chown ${USERNAME}:${USER_GID} -R /app \
  && chown ${USERNAME}:${USER_GID} -R /opt

# Change default user
USER ${USERNAME}

ENTRYPOINT [ "/docker-entrypoint.sh" ]


############################### stage ###############################
# This stage is used when running automated tests
FROM prod AS cicd

COPY ./requirements-cicd.txt /requirements-cicd.txt
RUN pip install -r /requirements-cicd.txt

ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "pytest", "-xvs" ]


############################### stage ###############################
# This stage is intended to be used for development purposes. It
# allows to develop the application within the container, e.g. using
# vscode remote containers plugin.
FROM cicd AS dev

USER root

# Add sudo support
RUN apt-get update \
  && apt-get install -y sudo \
  && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
  && chmod 0440 /etc/sudoers.d/$USERNAME

# Install packages for local development
RUN apt-get update \
  && apt-get install --no-install-recommends --no-install-suggests -y \
  build-essential \
  ca-certificates \
  curl \
  git \
  ssh \
  vim \
  && rm -rf /var/lib/apt/lists/*

COPY ./requirements-dev.txt /requirements-dev.txt
RUN pip install -r /requirements-dev.txt

COPY ./.docker/docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

ENV PYTHONPATH="${PYTHONPATH}:/app"
WORKDIR /app

# Change default user
USER ${USERNAME}

ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "sleep", "infinity" ]
