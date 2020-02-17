#### !!! THIS IS TO BE SOURCED BY test_scripts.sh !!!

### test for mem-phys-addr

# mem-phys-addr resolves physical address samples

script="mem-phys-addr"


# record
$CMD_PERF script record $script -a -o $CURRENT_TEST_DIR/perf.data -- $CMD_LONGER_SLEEP 2> $LOGS_DIR/script__${script}__record.log
PERF_EXIT_CODE=$?

../common/check_all_patterns_found.pl "$RE_LINE_RECORD1" "$RE_LINE_RECORD2" "perf.data" < $LOGS_DIR/script__${script}__record.log
CHECK_EXIT_CODE=$?

print_results $PERF_EXIT_CODE 0 "script $script :: record"
(( TEST_RESULT += $? ))


# report
$CMD_PERF script report $script -i $CURRENT_TEST_DIR/perf.data > $LOGS_DIR/script__${script}__report.log 2> $LOGS_DIR/script__${script}__report.err
PERF_EXIT_CODE=$?

REGEX_HEADER_EVENT="Event:.+"
REGEX_HEADER_LINE="Memory type\s+count\s+percentage"
REGEX_DATA_LINE="[\w+ \/\_\-]+\s+\d+\s+$RE_NUMBER%"

../common/check_all_patterns_found.pl "$REGEX_HEADER_EVENT" "$REGEX_HEADER_LINE" "$REGEX_DATA_LINE" < $LOGS_DIR/script__${script}__report.log
CHECK_EXIT_CODE=$?

print_results $PERF_EXIT_CODE $CHECK_EXIT_CODE "script $script :: report"
(( TEST_RESULT += $? ))


# sample count check
N_SAMPLES=`perl -ne 'print "$1" if /\((\d+) samples\)/' $LOGS_DIR/script__${script}__record.log`

CNT="0"
(( CNT += `perl -ne 'BEGIN{$n=0;}{$n+=$1 if (/\s*\S+\s+(\d+)\s+[\d.]+%/)} END{print "$n";}' < $LOGS_DIR/script__${script}__report.log` ))

test $CNT -eq $N_SAMPLES
print_results 0 $? "script $script :: sample count check ($CNT == $N_SAMPLES)"
(( TEST_RESULT += $? ))