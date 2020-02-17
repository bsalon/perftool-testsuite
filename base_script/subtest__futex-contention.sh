#### !!! THIS IS TO BE SOURCED BY test_scripts.sh !!!

### test for futex-contention

# futex-contention should show a summary of locks - how many times they were contended
# and its average time between the beginning and completion of a futex wait

script="futex-contention"


# record
$CMD_PERF script record $script -a -o $CURRENT_TEST_DIR/perf.data -- $CMD_BASIC_SLEEP 2> $LOGS_DIR/script__${script}__record.log
PERF_EXIT_CODE=$?

../common/check_all_patterns_found.pl "$RE_LINE_RECORD1" "$RE_LINE_RECORD2" "perf.data" < $LOGS_DIR/script__${script}__record.log
CHECK_EXIT_CODE=$?

print_results $PERF_EXIT_CODE 0 "script $script :: record"
(( TEST_RESULT += $? ))


# report
$CMD_PERF script report $script -i $CURRENT_TEST_DIR/perf.data > $LOGS_DIR/script__${script}__report.log 2> $LOGS_DIR/script__${script}__report.err
PERF_EXIT_CODE=$?

REGEX_HEADER_LINE="Press control\+C to stop and show the summary"
REGEX_DATA_LINE="[\w\-\_]+\[[0-9]+\] lock $RE_NUMBER_HEX contended $RE_NUMBER times, $RE_NUMBER avg ns"

../common/check_all_patterns_found.pl "$REGEX_HEADER_LINE" "$REGEX_DATA_LINE" < $LOGS_DIR/script__${script}__report.log
CHECK_EXIT_CODE=$?

print_results $PERF_EXIT_CODE $CHECK_EXIT_CODE "script $script :: report"
(( TEST_RESULT += $? ))


# syscall count check
N_SAMPLES=`$CMD_PERF report -i $CURRENT_TEST_DIR/perf.data --stdio | perl -ne 'print "$1" if /^#\sSamples:\s(\d+)\s+of\s+event.+syscalls:sys_enter_futex/'`
(( N_SAMPLES += `$CMD_PERF report -i $CURRENT_TEST_DIR/perf.data --stdio | perl -ne 'print "$1" if /^#\sSamples:\s(\d+)\s+of\s+event.+syscalls:sys_exit_futex/'` ))

CNT=`perl -ne 'print "$1" if /\((\d+) samples\)/' $LOGS_DIR/script__${script}__record.log`

test $CNT -eq $N_SAMPLES
print_results 0 $? "script $script :: syscall count check ($CNT == $N_SAMPLES)"
(( TEST_RESULT += $? ))

