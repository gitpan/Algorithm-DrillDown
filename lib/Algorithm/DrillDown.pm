package Algorithm::DrillDown;
{
  $Algorithm::DrillDown::DIST = 'Algorithm-DrillDown';
}
{
  $Algorithm::DrillDown::VERSION = '0.006';
}
# ABSTRACT: Turns a long list into an easy-to-navigate tree
use Moose;
use MooseX::Types -declare => [qw/ NonEmptyIntArrayRef /];
use MooseX::Types::Moose qw/ Int ArrayRef CodeRef /;

subtype NonEmptyIntArrayRef,
    as ArrayRef[Int],
    where { @$_ && !grep($_<=0, @$_) },
    message { "List of depths must not be empty nor contain nonpositive integers" }
    ;

coerce NonEmptyIntArrayRef,
    from ArrayRef[Int], via { $_ },
    from Int, via { [$_] },
    ;

has maxitems => ( is => 'rw', isa => NonEmptyIntArrayRef, default => 32, coerce => 1, auto_deref => 1);
has maxdepth => ( is => 'rw', isa => Int, default => 8);
has slicer => ( is => 'rw', isa => CodeRef, default => sub { return \&_slicer_string } );

use Carp;


sub generate {
    my($self, $list) = @_;
    # we start off with a tree with everything in a top-level bucket
    my %tree = ('' => $list);

    for my $level (0..$self->maxdepth) {
        my $maxitems = $self->maxitems->[$level] // $self->maxitems->[-1];
        my $splitcount;
        foreach my $key (keys %tree) {
            my $list = $tree{$key};
            next if $#$list <= $maxitems;

            # this bucket is too full, so we split it to the next level
            delete $tree{$key};
            ++$splitcount;
            foreach my $item (@$list) {
                my $prefix = $self->slicer->($self, $level, $item);
                push @{$tree{$prefix}||=[]}, $item;
            }

        }
        # if nothing was split, everything was clearly in small-enough buckets
        # so we're done
        last unless $splitcount;
    }

    return wantarray ? %tree : \%tree;
}


sub _slicer_string {
    my(undef, $level, $string) = @_;
    return substr $string, 0, $level;
}


1;

__END__

=pod

=head1 NAME

Algorithm::DrillDown - Turns a long list into an easy-to-navigate tree

=head1 VERSION

version 0.006

=head1 SYNOPSIS

 my $drilldown = new Algorithm::DrillDown;
 my $tree = $drilldown->generate(\@authors);
 print Dump $tree;

 sub myslicer {
   my($drilldown, $level, $string) = @_;
   $string =~ tr/0-9A-Za-z//cd;
   return substr lc $string, 0, $level;
 }

 my $drilldown_custom = new Algorithm::DrillDown
      slicer => \&myslicer,
      maxitems => 32,
      maxdepth => 8;

=head1 DESCRIPTION

This module was written because I kept tripping over lists of data that were
too large and unwieldy to display directly and wanted a means of grouping them
into a hierarchy that could be more easily navigated.

By way of specific example, I wanted a list of CPAN authors on a web page, but
as there are over six thousand of them, putting them all on a single page was
not sensible. The most obvious solution would be to just arbitrarily split
after every few hundred authors and put a "more" button, but that's just icky.
Wouldn't it be nicer if one could just click on "MO" (or "MOBILEART..MOXFYRE")
then "MOOLI" than randomly-guess that it's probably around page eleven of
twenty?

Similarly, I archive mailing lists in IMAP folders backed by a Maildir, but
these folders get kind of big and unwieldy after a while and I'd like to
automatically decide that an archive folder is getting too large and split it
into multiple dated folders.

This object-wraps an otherwise stateless operation which takes an input list
and produces a hash-of-array. The hash keys are the result of your slicer
function, and the values are your input values that produced that result. The
items will be placed into the least-specific grouping that will still ensure
that the array is not larger than maxitems.

A specific example may help. The default slicer function is substr, so "least
specific" means "shortest prefix". So if we start with something like:

 my @list = qw / AADLER AAKD AAKHTER AALLAN AANKHEN AANZLOVAR AAR AARDEN AARDO
 AARE AARON AARONJJ AARONSCA AASSAD AAU AAYARS ABALAMA ABARCLAY ABCDEFGH ABE
 ABELEW ABELTJE ABERGMAN ABERNDT ABEROHAM ABH ABHAS ABHIDHAR ZTURK ZUMMO ZUQIF
 ZURAWSKI ZZCGUMK /;

then a rather compressed/obfuscated invocation:

 my $result = Algorithm::DrillDown->new(maxitems => 16)->generate(\@list);

And the end result is a structure like this:

 my $result = {
      AA => [qw/ AADLER AAKD AAKHTER AALLAN AANKHEN AANZLOVAR AAR
                AARDEN AARDO AARE AARON AARONJJ AARONSCA AASSAD AAU
                AAYARS /],
     AB => [qw/ ABALAMA ABARCLAY ABCDEFGH ABE ABELEW ABELTJE ABERGMAN
                ABERNDT ABEROHAM ABH ABHAS ABHIDHAR /],
     Z => [qw/ ZTURK ZUMMO ZUQIF ZURAWSKI ZZCGUMK /],
 };

Note that the lists are not guaranteed to be in any particular order. (The hash
is obviously unsorted too.)

=for test_synopsis my @authors;

=head1 MOOSE FIELDS

=head2 slicer

A reference to your slicer function, that is one that takes the
Algorithm::DrillDown object, a level (an integer, starting at zero) and your
input scalar (which does not have to be a string) and returns a string which
summarises that input at the given level.

The default function is based on substr, and returns the string truncated to
the same number of characters as the level.

=head2 maxitems

The maximum number of items to place in an output array. Note that an array may
still exceed this value if maxdepth has been reached first.

=head2 maxdepth

The maximum level that will be passed to your slicer function. This mainly
serves to prevent an infinite loop in the case where it is impossible to split
the item list to havefewer than maxitems in an output array.

=head1 METHODS

=head2 generate

Returns a hash-of-list or hashref-of-list (depending on context) of the longest
common substring (or other string as obtained from the slicer) to the items
that have been placed into that list.

=head1 PRIVATE METHODS

=head2 _slicer_string

The default slicer impementation, which splits strings on character boundaries.

=head1 BUGS

Pathological data will cause more than maxitems items to appear in a bucket,
and also this will cause it to appear at the maxdepth level. Since it works
well enough for now, this is not being checked for. There are loads of possibly
icky edge cases.

=head1 AUTHOR

Peter Corlett <abuse@cabal.org.uk>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Peter Corlett.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
