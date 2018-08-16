#!/usr/bin/env sh
#
# Bacula service

# import DroboApps framework functions
. /etc/service.subr

framework_version="2.1"
name="bacula"
version="9.2.1"
description="Bacula is a set of computer programs that permit managing backup, recovery, and verification of computer data."
depends=""
webui=""

prog_dir="$(dirname "$(realpath "${0}")")"
conf_dir="${prog_dir}/etc"
sbin_dir="${prog_dir}/sbin"
pid_dir="${prog_dir}/var/run"

# Storage Daemon
sd_daemon="${sbin_dir}/bacula-sd"
sd_config="${conf_dir}/bacula-sd.conf"
sd_port="9103"
sd_pid="${pid_dir}/bacula-sd.${sd_port}.pid"

# File Daemon
fd_daemon="${sbin_dir}/bacula-fd"
fd_config="${conf_dir}/bacula-fd.conf"
fd_port="9102"
fd_pid="${pid_dir}/bacula-fd.${fd_port}.pid"

# Director Daemon
dir_daemon="${sbin_dir}/bacula-dir"
dir_config="${conf_dir}/bacula-dir.conf"
dir_port="9101"
dir_pid="${pid_dir}/bacula-dir.${dir_port}.pid"

_start_daemon() {

   # Test syntax.
   if [ $# = 0 ] && [ $# <> 3 ]; then
      echo "Usage: _start_daemon {daemon} {config}"
      return 1
   fi

  daemon=${1};
  config=${2};
  pid_file=${3};

  if [ -x "${daemon}" ]; then

    /sbin/start-stop-daemon -K -t -x "${daemon}" -p "${pid_file}" -q
    rc=$?
    if [ "${rc}" == 0 ]; then
      echo "${daemon} already running";
    else
      echo "Starting ${daemon} -c -v ${config}";
      "${daemon}" -c -v "${config}"
    fi

  else

    echo "${daemon} not found"

  fi

}

_service_start() {

  # Storage Daemon
  _start_daemon "${sd_daemon}" "${sd_config}" "${sd_pid}";

  # File Daemon
  _start_daemon "${fd_daemon}" "${fd_config}" "${fd_pid}";

  # Director Daemon
  _start_daemon "${dir_daemon}" "${dir_config}" "${dir_pid}";

}
  
_status_daemon() {

   # Test syntax.
   if [ $# = 0 ] && [ $# <> 2 ]; then
      echo "Usage: _status_daemon {daemon} {pid_file}"
      return 1
   fi

  daemon=${1};
  pid_file=${2};

  `/sbin/start-stop-daemon -K -t -x "${daemon}" -p "${pid_file}" -q`
  rc=$?
  if [ "${rc}" == 0 ]; then
    echo "${daemon} running";
  else
    echo "${daemon} not running";
  fi

}

_service_status() {

  # Storage Daemon
  _status_daemon "${sd_daemon}" "${sd_pid}";

  # File Daemon
  _status_daemon "${fd_daemon}" "${fd_pid}";

  # Director Daemon
  _status_daemon "${dir_daemon}" "${dir_pid}";

}

_stop_daemon() {

   # Test syntax.
   if [ $# = 0 ] && [ $# <> 2 ]; then
      echo "Usage: _stop_daemon {daemon} {pid_file}"
      return 1
   fi

  daemon=${1};
  pid_file=${2};

  # add -t if you want a dry-run
  /sbin/start-stop-daemon -K -x "${daemon}" -p "${pid_file}" 
  rc=$?
  if [ "$rc" == 0 ]; then
    rm "${pid_file}";
  fi

}

_service_stop() {

  # File Daemon
  _stop_daemon "${fd_daemon}" "${fd_pid}";

  # Storage Daemon
  _stop_daemon "${sd_daemon}" "${sd_pid}";

  # Director Daemon
  _stop_daemon "${dir_daemon}" "${dir_pid}";

}
  
  
# boilerplate
#set -o errexit  # exit on uncaught error code
set -o nounset  # exit on unset variable
#set -o xtrace   # enable script tracing

case "${1:-}" in
  start|stop|restart|status) _service_${1} ;;
  *) _service_help ;;
esac
