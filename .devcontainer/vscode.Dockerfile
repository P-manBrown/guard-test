FROM ruby:2.7.5

ARG APP_NAME=myapp-backend
ARG USER_NAME=ruby
ENV RUBYGEMS_VERSION=3.3.17
ENV TZ=Asia/Tokyo
ENV XDG_CONFIG_DIRS=/${APP_NAME}

RUN adduser ${USER_NAME}

RUN apt-get update -qq && apt-get install -y nodejs

COPY --chown=${USER_NAME} Gemfile Gemfile.lock /${APP_NAME}/
WORKDIR /${APP_NAME}
RUN --mount=type=secret,id=github-pkg-cred,required \
    BUNDLE_RUBYGEMS__PKG__GITHUB__COM=$(cat /run/secrets/github-pkg-cred) \
    export BUNDLE_RUBYGEMS__PKG__GITHUB__COM \
    && gem update --system ${RUBYGEMS_VERSION} \
    && bundle install \
    && chown -R ${USER_NAME} ${GEM_HOME}

COPY --chmod=755 /docker/api/entrypoint.sh /usr/bin/
ENTRYPOINT ["entrypoint.sh"]

USER ${USER_NAME}
RUN mkdir -p /${APP_NAME}/tmp/sockets \
    && mkdir -p /${APP_NAME}/public

RUN gem install solargraph-rails --pre \
    && solargraph download-core \
    && mkdir -p /home/${USER_NAME}/.yard \
    && SHOULD_RUN_YARD_GEMS='\
        \n function should_run_yard_gems() { \n\
          \t if [[ `history 1` =~ ^.*bundle( +((install|-+).*$)| *$) ]] ; then \n\
            \t\t printf "\x1b[1m%s\n" "Running [yard gems] to generate documentation for your installed gems." \n\
            \t\t yard gems \n\
          \t fi \n\
        }\
        '\
    && echo ${SHOULD_RUN_YARD_GEMS} >> "/home/${USER_NAME}/.bashrc"

RUN RECODE_BASH_LOG='\
      \n if [ "$SHLVL" = "2" ] ; then \n\
        \t script -f ~/bashlog/script/`date "+%Y%m%d%H%M%S"`.log \n\
      fi \n\
    '\
    EXPORT_PROMPT_COMMAND='\
      \n export PROMPT_COMMAND="history -a && should_run_yard_gems"\
    '\
    EXPORT_HISTFILE='\n export HISTFILE=~/bashlog/.bash_history' \
    && mkdir -p /home/${USER_NAME}/bashlog/script \
    && touch /home/${USER_NAME}/bashlog/.bash_history \
    && echo ${RECODE_BASH_LOG}${EXPORT_PROMPT_COMMAND}${EXPORT_HISTFILE} \
        >> "/home/${USER_NAME}/.bashrc"

RUN mkdir -p /home/${USER_NAME}/.vscode-server/extensions

EXPOSE 3000
