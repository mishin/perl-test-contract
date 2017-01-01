#!/usr/bin/env perl

use strict;
use warnings;

use Test::Refute;
use Test::Refute::TAP;

sub contract_out (&;$); ## no critic

my $content;

$content = contract_out {
    note "Foo";
};
is $content, "## Foo\n1..0\n", "note works";

$content = contract_out {
    diag "Foo";
};
is $content, "# Foo\n1..0\n", "diag works";

$content = contract_out {
    is (1, 1, "Equal");
};
is $content, "ok 1 - Equal\n1..1\n", "is happy path";

$content = contract_out {
    is (1, 0, "False");
} 1;
is $content, "not ok 1 - False\n1..1\n", "is when it really isn't";

$content = contract_out {
    cmp_ok( 1, ">", 0, "more" );
    cmp_ok( 1, "<", 0, "no more" );
} 1;
is $content, "ok 1 - more\nnot ok 2 - no more\n1..2\n", "cmp_ok smoke";

$content = contract_out {
    like( 42, qr(\d), "like (sigh...)" );
    like( 42, qr(\d+), "like" );
} 1;
is $content, "ok 1 - like (sigh...)\nok 2 - like\n1..2\n", "like smoke";

$content = contract_out {
    like( "program", "o|g", "unlike" );
    like( "program", ".*o|g.*", "unlike" );
    like( "program", ".*(o|g).*", "like" );
} 1;
is $content
    , "not ok 1 - unlike\nnot ok 2 - unlike\nok 3 - like\n1..3\n"
    , "like smoke w/o qr()";

done_testing;

sub contract_out(&;$) { ## no critic
    my ($code, $strip) = @_;

    my $content = '';
    open my $fd, ">", \$content
        or die "Failed to redirect: $!";

    &contract( $code, Test::Refute::TAP->new( out => $fd ) );
    $content =~ s/#.*?\n//gs
        if $strip;
    return $content;
};
