#!/usr/bin/perl

@regexps = @ARGV;

$quiet = 1;
$quiet = 0 if (defined $ENV{TESTLOG_VERBOSITY} && $ENV{TESTLOG_VERBOSITY} ge 2);

$passed = 1;
$r = 0.0;
$P = 0.0;

while (<STDIN>)
{
	s/\n//;

	# skip lines with unpaired syscalls (continued ones that had been started before perf attached), such as:
	#          ? (     ?   ): something/732  ... [continued]: poll()) = 0 Timeout
	next if /^\s+\?\s*\(\s+\?/;

	($p) = $_ =~ /^\s*(\d+(?:\.\d+))\s/;
	$p *= 1.0;

	unless ($p >= $r)
	{
		print "Invalid timestamp: $p is lower than $r (previous one)\n" unless $quiet;
		exit 1;
	}
	$r = $p;
}


exit 0;
