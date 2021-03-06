#
#	parametrization.sh
#	Author: Michael Petlan <mpetlan@redhat.com>
#
#	Description:
#
#		This file configures the testcases how deeply they should
#	look at things. The parametrization allows you to use the suite
#	for both smoke testing and deeper testing.
#

#### general

export PARAM_GENERAL_HELP_TEXT_CHECK=${PARAM_GENERAL_HELP_TEXT_CHECK:-y}


#### perf_stat

export PARAM_STAT_24x7_ALL_CORES=${PARAM_STAT_24x7_ALL_CORES:-y}
export PARAM_STAT_24x7_ALL_DOMAINS=${PARAM_STAT_24x7_ALL_DOMAINS:-y}
export PARAM_STAT_TRACEPOINT_EVENTS_SYNTAX=${PARAM_STAT_TRACEPOINT_EVENTS_SYNTAX:-y}
export PARAM_STAT_ALL_PMU_EVENTS=${PARAM_STAT_ALL_PMU_EVENTS:-y}
export PARAM_STAT_TEST_METRICS=${PARAM_STAT_TEST_METRICS:-y}


#### perf_record

export PARAM_RECORD_CALLGRAPH_FP=${PARAM_RECORD_CALLGRAPH_FP:-y}
export PARAM_RECORD_CALLGRAPH_DWARF=${PARAM_RECORD_CALLGRAPH_DWARF:-y}

