LOG=/tmp/eqosplus_tmp.log
IPT_LOG=/tmp/eqosplus_ipt.log
# handling of specific important binaries
[ -z "$TC" ] && TC=tc_wrapper
[ -z "$TC_BINARY" ] && TC_BINARY=$(which tc)
[ -z "$IP" ] && IP=ip_wrapper
[ -z "$IP_BINARY" ] && IP_BINARY=$(which ip)
[ -z "$IPTABLES" ] && IPTABLES=iptables_wrapper
[ -z "$IPTABLES_BINARY" ] && IPTABLES_BINARY=$(which iptables)
[ -z "$IP6TABLES" ] && IP6TABLES=ip6tables_wrapper
[ -z "$IP6TABLES_BINARY" ] && IP6TABLES_BINARY=$(which ip6tables)


# Try modprobe first, fall back to insmod
[ -z "$INSMOD" ] && INSMOD=$(which modprobe) || INSMOD=$(which insmod)

# Logging verbosity
VERBOSITY_SILENT=0
VERBOSITY_ERROR=1
VERBOSITY_WARNING=2
VERBOSITY_INFO=5
VERBOSITY_DEBUG=8
VERBOSITY_TRACE=10

sqm_logger() {
    local level_min
    local level_max
    local debug

    case $1 in
        ''|*[!0-9]*) LEVEL=$VERBOSITY_INFO ;; # empty or non-numbers
        *) LEVEL=$1; shift ;;
    esac

    level_min=${SQM_VERBOSITY_MIN:-$VERBOSITY_SILENT}
    level_max=${SQM_VERBOSITY_MAX:-$VERBOSITY_INFO}
    debug=${SQM_DEBUG:-0}

    if [ "$level_max" -ge "$LEVEL" ] && [ "$level_min" -le "$LEVEL" ] ; then
        if [ "$SQM_SYSLOG" -eq "1" ]; then
            logger -t SQM -s "$*"
        else
            echo "$@" >&2
        fi
    fi

    # this writes into SQM_START_LOG or SQM_STOP_LOG, log files are trucated in
    # start-sqm/stop-sqm respectively and should only take little space
    if [ "$debug" -eq "1" ]; then
        echo "$@" >> "${SQM_DEBUG_LOG}"
    fi
}

sqm_error() { sqm_logger $VERBOSITY_ERROR ERROR: "$@"; }
sqm_warn() { sqm_logger $VERBOSITY_WARNING WARNING: "$@"; }
sqm_log() { sqm_logger $VERBOSITY_INFO "$@"; }
sqm_debug() { sqm_logger $VERBOSITY_DEBUG "$@"; }
sqm_trace() { sqm_logger $VERBOSITY_TRACE "$@"; }

ipt_log()
{
    echo "$@" >> $IPT_LOG
}

# wrapper to call iptables to allow debug logging
iptables_wrapper(){
    cmd_wrapper iptables ${IPTABLES_BINARY} "$@"
}

# wrapper to call ip6tables to allow debug logging
ip6tables_wrapper(){
    cmd_wrapper ip6tables ${IP6TABLES_BINARY} "$@"
}

# the actual command execution wrapper
cmd_wrapper(){
    # $1: the symbolic name of the command for informative output
    # $2: the name of the binary to call (potentially including the full path)
    # $3-$end: the actual arguments for $2
    local CALLERID
    local CMD_BINARY
    local LAST_ERROR
    local RET
    local ERRLOG

    CALLERID=$1 ; shift 1   # extract and remove the id string
    CMD_BINARY=$1 ; shift 1 # extract and remove the binary

    # Handle silencing of errors from callers
    ERRLOG="sqm_error"
    if [ "$SILENT" -eq "1" ]; then
        ERRLOG="sqm_debug"
        sqm_debug "cmd_wrapper: ${CALLERID}: invocation silenced by request, FAILURE either expected or acceptable."
        # The busybox shell doesn't understand the concept of an inline variable
        # only applying to a single command, so we need to reset SILENT
        # afterwards. Ugly, but it works...
        SILENT=0
    fi

    sqm_trace "cmd_wrapper: COMMAND: ${CMD_BINARY} $@"
    LAST_ERROR=$( ${CMD_BINARY} "$@" 2>&1 )
    RET=$?

    if [ "$RET" -eq "0" ] ; then
        sqm_debug "cmd_wrapper: ${CALLERID}: SUCCESS: ${CMD_BINARY} $@"
    else
        # this went south, try to capture & report more detail
        $ERRLOG "cmd_wrapper: ${CALLERID}: FAILURE (${RET}): ${CMD_BINARY} $@"
        $ERRLOG "cmd_wrapper: ${CALLERID}: LAST ERROR: ${LAST_ERROR}"
    fi

    return $RET
}

ipt() {
    local neg

    for var in "$@"; do
        case "$var" in
            "-A"|"-I"|"-N")
                # If the rule is an addition rule, we first run its negation,
                # then log that negation to be used by ipt_log_rewind() on
                # shutdown
                neg="$(ipt_negate "$@")"
                ipt_run_split "$neg"
                ipt_log "$neg"
                ;;
        esac
    done

    SILENT=1 ${IPTABLES} "$@"
    SILENT=1 ${IP6TABLES} "$@"
}
