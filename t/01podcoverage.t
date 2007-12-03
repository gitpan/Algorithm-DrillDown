#!/usr/bin/env perl
use warnings;
use strict;

use Test::More;
eval "use Test::Pod::Coverage 1.04";
plan(
     skip_all => 'Test::Pod::Coverage 1.04 required for testing POD coverage'
    ) if $@;

use vars qw( $TODO );

TODO: {

#local $TODO = "Documentation, we've heard of it";
all_pod_coverage_ok( "Algorithm::DrillDown"); #, "Foo::Bar is covered" );

}
