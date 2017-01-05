package Test::Simple;

use strict;
use warnings;
our $VERSION = 0.01;

=head1 STOP!

This is a fake Test::More.
It is only here to test how Test::Refute behaves in place of Test::More
without rewriting a lot of test scripts.

=cut

use Test::Refute;
use Carp;

# Just re-export everything
our @ISA = qw(Test::Refute Exporter);
our @EXPORT = @Test::Refute::EXPORT;

END {
    if (Test::Builder->can("import")) {
        carp "Real Test::More loaded, the script may misbehave";
    };
};

1;
