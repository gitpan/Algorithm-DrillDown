#!/usr/bin/env perl
use warnings;
use strict;
use Test::Most;

use_ok('Algorithm::DrillDown');

 my @list = qw/ AADLER AAKD AAKHTER AALLAN AANKHEN AANZLOVAR AAR AARDEN
 AARDO AARE AARON AARONJJ AARONSCA AASSAD AAU AAYARS ABALAMA ABARCLAY
 ABCDEFGH ABE ABELEW ABELTJE ABERGMAN ABERNDT ABEROHAM ABH ABHAS ABHIDHAR
 ZTURK ZUMMO ZUQIF ZURAWSKI ZZCGUMK /;

my $result = Algorithm::DrillDown
    ->new(maxitems => 16)
    ->generate(\@list);

my $expected = {
    AA => [qw/ AADLER AAKD AAKHTER AALLAN AANKHEN AANZLOVAR AAR
               AARDEN AARDO AARE AARON AARONJJ AARONSCA AASSAD AAU
               AAYARS /],
    AB => [qw/ ABALAMA ABARCLAY ABCDEFGH ABE ABELEW ABELTJE ABERGMAN
               ABERNDT ABEROHAM ABH ABHAS ABHIDHAR /],
    Z => [qw/ ZTURK ZUMMO ZUQIF ZURAWSKI ZZCGUMK /],
};

eq_or_diff($result, $expected, "generated the expected drilldown");

# FIXME: test undocumented array-of-depths functionality

done_testing();


