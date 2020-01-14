#!/bin/sh

set -ex

_UID=${1}
_GID=${2}

if test ${_UID} -eq 0; then
  _UID="";
  _GID="";
fi

UID_TAKEN="$(getent passwd "${_UID}" | cut -d: -f1)"
if test -n "${UID_TAKEN}"; then
  deluser --remove-home "${UID_TAKEN}"
fi

GID_TAKEN="$(getent group "${_GID}" | cut -d: -f1)"
if test -n "${GID_TAKEN}"; then
  delgroup "${GID_TAKEN}"
fi

if test -n "${_GID}"; then
  addgroup \
    --gid "${_GID}" \
    --system \
    "${APPUSER}";
else
  _GID=$(addgroup --system ${APPUSER} | grep -Eo '[0-9]+');
fi

if test -n "${_UID}"; then
  adduser \
    --uid "${_UID}" \
    --system \
    --disabled-password \
    --ingroup "${APPUSER}" \
    --home "${HOME}" \
    --shell /sbin/nologin \
    "${APPUSER}"
else
  adduser \
    --system \
    --disabled-password \
    --ingroup "${APPUSER}" \
    --home "${HOME}" \
    --shell /sbin/nologin \
    "${APPUSER}"
fi

# chown -R "${APPUSER}":"${APPUSER}" "${HOME}" "${SRCDIR}"
