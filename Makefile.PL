#!/usr/bin/env perl
use warnings;
use strict;

# $Id: Makefile.PL 6 2007-12-02 19:09:12Z abuse $
our $VERSION = do {
  my @r=(q$Revision: 6 $=~/\d+/g); sprintf "%d."."%03d"x$#r,@r
};

use ExtUtils::MakeMaker;
eval "use ExtUtils::MakeMaker::Coverage";
warn "Note: ExtUtils::MakeMaker::Coverage not available, can't 'make testcover'\n"
  if $@;

WriteMakefile(
	      NAME     => 'Algorithm::DrillDown',
	      VERSION  => '0.001'
	     );
