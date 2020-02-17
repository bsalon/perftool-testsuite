#### !!! THIS IS TO BE SOURCED BY test_scripts.sh !!!

### test for net_dropmonitor script

# net_dropmonitor script should print a table of dropped frames


script="net_dropmonitor"


# record
$CMD_PERF script record $script -a -o $CURRENT_TEST_DIR/perf.data -- $CMD_BASIC_SLEEP 2> $LOGS_DIR/script__${script}__record.log
PERF_EXIT_CODE=$?

../common/check_all_patterns_found.pl "$RE_LINE_RECORD1" "$RE_LINE_RECORD2_TOLERANT" "perf.data" < $LOGS_DIR/script__${script}__record.log
CHECK_EXIT_CODE=$?

print_results $PERF_EXIT_CODE $CHECK_EXIT_CODE "script $script :: record"
(( TEST_RESULT += $? ))


# report
$CMD_PERF script report $script -i $CURRENT_TEST_DIR/perf.data > $LOGS_DIR/script__${script}__report.log 2> $LOGS_DIR/script__${script}__report.err
PERF_EXIT_CODE=$?

REGEX_HEADER_LINE1="Starting trace \(Ctrl-C to dump results\)"
REGEX_HEADER_LINE2="Gathering kallsyms data"

../common/check_all_patterns_found.pl "$REGEX_HEADER_LINE1" "$REGEX_HEADER_LINE2" < $LOGS_DIR/script__${script}__report.log
CHECK_EXIT_CODE=$?
../common/check_all_patterns_found.pl "LOCATION" "OFFSET" "COUNT" < $LOGS_DIR/script__${script}__report.log
(( CHECK_EXIT_CODE += $? ))

print_results $PERF_EXIT_CODE $CHECK_EXIT_CODE "script $script :: report"
(( TEST_RESULT += $? ))


# sample count check
N_SAMPLES=`perl -ne 'print "$1" if /\((\d+) samples\)/' $LOGS_DIR/script__${script}__record.log`
if [ -z $N_SAMPLES ]; then
        N_SAMPLES="0"
fi

CNT=`perl -ne 'BEGIN{$n=0;$en=0;}{$n+=$1 if ($en&&/\s*\S+\s+\d+\s+(\d+)/);$en=1 if /\s*LOCATION\s+OFFSET\s+COUNT/;$en=0 if /^\s*$/} END{print "$n";}' < $LOGS_DIR/script__${script}__report.log`
if [ -z $CNT ]; then
	CNT="0"
fi

test $CNT -eq $N_SAMPLES
print_results 0 $? "script $script :: sample count check ($CNT == $N_SAMPLES)"
(( TEST_RESULT += $? ))
