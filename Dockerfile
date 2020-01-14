FROM jozian/primero-base:latest

ARG RAILS_ENV

ENV APPUSER=primero
ENV HOME=/srv/${APPUSER}
ENV RAILS_ENV=${RAILS_ENV:-development}

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

WORKDIR ${SRCDIR}
USER ${APPUSER}

COPY . .

ENV TARGETS="--without test development cucumber"
RUN if [ "${RAILS_ENV}" = "production" ]; then \
            bundle install -j$(grep processor /proc/cpuinfo | wc -l) --without test development cucumber; \
            else \
            bundle install -j$(grep processor /proc/cpuinfo | wc -l); \
            fi;

ENTRYPOINT ["./docker/app/entrypoint"]
