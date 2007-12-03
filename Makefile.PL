#!/usr/bin/env perl
use warnings;
use strict;

use vars qw( $VERSION );

# $Id: Makefile.PL 13 2007-12-03 22:10:38Z abuse $
$VERSION = do {
  my @r=(q$Revision: 13 $=~/\d+/g); sprintf "%d."."%03d"x$#r,@r
};

use ExtUtils::MakeMaker;
eval "use ExtUtils::MakeMaker::Coverage";
warn "Note: ExtUtils::MakeMaker::Coverage not available, can't 'make testcover'\n"
  if $@;

WriteMakefile(
              ABSTRACT => 'Turns a long list into an easy-to-navigate tree',
	      NAME     => 'Algorithm::DrillDown',
	      VERSION  => '0.003',
              PREREQ_PM => {},
	     );
