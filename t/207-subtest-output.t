#!/usr/bin/env perl

use strict;
use warnings;
use Test::Refute;
use Test::Refute::TAP;

my $output;
open (my $fd, ">", \$output)
    or die "Redirect failed";

my $c = Test::Refute::TAP->new( out => $fd );

contract {
    ok 1;
    subtest pass => sub {
        ok 1;
    };
    subtest fail => sub {
        ok 1;
        ok 0;
    };
    ok 1;
} $c;

note $output;

$output =~ s/^ *#.*$//mg;
$output =~ s/\n\n+/\n/gs;
is ($output, <<OUT, "Would-be output as expected");
ok 1 - test 1
    ok 1 - test 1
    1..1
ok 2 - pass
    ok 1 - test 1
    not ok 2 - test 2
    1..2
not ok 3 - fail
ok 4 - test 4
1..4
OUT

done_testing;