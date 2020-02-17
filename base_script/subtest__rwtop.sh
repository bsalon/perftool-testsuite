#### !!! THIS IS TO BE SOURCED BY test_scripts.sh !!!

### test for rwtop script

# rwtop script displays system-wide read and write call activity


script="rwtop"


# record
$CMD_PERF script record $script -o $CURRENT_TEST_DIR/perf.data -- $CMD_SIMPLE 2> $LOGS_DIR/script__${script}__record.log
PERF_EXIT_CODE=$?

# note: this script does not produce any record output

print_results $PERF_EXIT_CODE 0 "script $script :: record"
(( TEST_RESULT += $? ))


# report
$CMD_PERF script report $script -i $CURRENT_TEST_DIR/perf.data > $LOGS_DIR/script__${script}__report.log 2> $LOGS_DIR/script__${script}__report.err
PERF_EXIT_CODE=$?

REGEX_READ_HEADER1="read counts by pid:"
REGEX_READ_HEADER2="\s+pid\s+comm\s+#\sreads\s+bytes_req\s+bytes_read"
REGEX_READ_LINE="\s*\d+\s+[\w\-\_]+\s+\d+\s+\d+\s+\d+"
REGEX_WRITE_HEADER1="write counts by pid:"
REGEX_WRITE_HEADER2="\s+pid\s+comm\s+#\swrites\s+bytes_written"
REGEX_WRITE_LINE="\s*\d+\s+[\w\-\_]+\s+\d+\s+\d+\s+"

../common/check_all_patterns_found.pl "$REGEX_READ_HEADER1" "$REGEX_READ_HEADER2" "$REGEX_WRITE_HEADER1" "$REGEX_WRITE_HEADER2" < $LOGS_DIR/script__${script}__report.log
CHECK_EXIT_CODE=$?
../common/check_all_patterns_found.pl "$REGEX_READ_LINE" "$REGEX_WRITE_LINE" < $LOGS_DIR/script__${script}__report.log
(( CHECK_EXIT_CODE += $? ))

print_results $PERF_EXIT_CODE $CHECK_EXIT_CODE "script $script :: report"
(( TEST_RESULT += $? ))


# syscall count check
N_SAMPLES=`perl -ne 'print "$1" if /\((\d+) samples\)/' $LOGS_DIR/script__${script}__record.log`

CNT="0"
for WHAT in "enter_read" "exit_read" "enter_write" "exit_write"; do
	(( CNT += `$CMD_PERF report -i $CURRENT_TEST_DIR/perf.data --stdio | perl -ne 'print "$1" if /^#\sSamples:\s(\d+)\s+of\s+event.+syscalls:sys_'$WHAT'/'` ))
done

test $CNT -eq $N_SAMPLES
print_results 0 $? "script $script :: syscall count check ($CNT == $N_SAMPLES)"
(( TEST_RESULT += $? ))

