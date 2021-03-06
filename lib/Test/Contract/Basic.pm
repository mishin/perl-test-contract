package Test::Contract::Basic;

use strict;
use warnings;
our $VERSION = 0.0204;

=head1 NAME

Test::Contract::Basic - a set of most common tests for Test::Contract suite

=head1 DESCRIPTION

B<DO NOT USE THIS MODULE DIRECTLY>.
Instead, load L<Test::Contract> for functional interface,
or L<Test::Contract::Engine> for object-oriented one.
Both would preload this module.

This module contains most common test conditions similar to those in
L<Test::More>, like C<is $got, $expected;> or C<like $got, qr/.../>.
Please refer here for an up-to-date reference.

=head1 FUNCTIONS

All functions are prototyped to be used without parentheses and
exported by default.
In addition, a C<Test::Contract::Engine-E<gt>function_name> method with
the same signature is generated for each of them (see L<Test::Contract::Build>).

=cut

use Carp;
use parent qw(Exporter);
use Test::Contract::Build;
our @EXPORT;

=head2 is $got, $expected, "explanation"

Check for equality, undef equals undef and nothing else.

=cut

build_refute is => sub {
    my ($got, $exp) = @_;

    if (defined $got xor defined $exp) {
        return "unexpected ". to_scalar($got, 0);
    };

    return '' if !defined $got or $got eq $exp;
    return sprintf "Got:      %s\nExpected: %s"
        , to_scalar($got, 0), to_scalar($exp, 0);
}, args => 2, export => 1;

=head2 isnt $got, $expected, "explanation"

The reverse of is().

=cut

build_refute isnt => sub {
    my ($got, $exp) = @_;
    return if defined $got xor defined $exp;
    return "Unexpected: ".to_scalar($got)
        if !defined $got or $got eq $exp;
}, args => 2, export => 1;

=head2 ok $condition, "explanation"

=cut

build_refute ok => sub {
    my $got = shift;

    return !$got;
}, args => 1, export => 1;

=head2 use_ok

Not really tested well.

=cut

# TODO write it better
build_refute use_ok => sub {
    my ($mod, @arg) = @_;
    my $caller = caller(1);
    eval "package $caller; use $mod \@arg; 1" and return ''; ## no critic
    return "Failed to use $mod: ".($@ || "(unknown error)");
}, no_pop => 1, export => 1;

build_refute require_ok => sub {
    my ($mod, @arg) = @_;
    my $caller = caller(1);
    eval "package $caller; require $mod; 1" and return ''; ## no critic
    return "Failed to require $mod: ".($@ || "(unknown error)");
}, args => 1, export => 1;

=head2 cpm_ok $arg, 'operation', $arg2, "explanation"

Currently supported: C<E<lt> E<lt>= == != E<gt>= E<gt>>
C<lt le eq ne ge gt>

Fails if any argument is undefined.

=cut

my %compare;
$compare{$_} = eval "sub { return \$_[0] $_ \$_[1]; }" ## no critic
    for qw( < <= == != >= > lt le eq ne ge gt );

build_refute cmp_ok => sub {
    my ($x, $op, $y) = @_;

    my @missing;
    push @missing, 1 unless defined $x;
    push @missing, 2 unless defined $y;
    return "Argument(@missing) undefined"
        if @missing;

    my $fun = $compare{$op};
    croak "cmp_ok(): Comparison '$op' not implemented"
        unless $fun;

    return '' if $fun->($x, $y);
    return "$x\nis not '$op'\n$y";
}, args => 3, export => 1;

=head2 like $got, qr/.../, "explanation"

=head2 like $got, "regexp", "explanation"

B<UNLIKE> L<Test::More>, accepts string argument just fine.

If argument is plain scalar, it is anchored to match the WHOLE string,
so that "foobar" does NOT match "ob", but DOES match ".*ob.*".

=head2 unlike $got, "regexp", "explanation"

The exact reverse of the above.

B<UNLIKE> L<Test::More>, accepts string argument just fine.

If argument is plain scalar, it is anchored to match the WHOLE string,
so that "foobar" does NOT match "ob", but DOES match ".*ob.*".

=cut

build_refute like => sub {
    _like_unlike( $_[0], $_[1], 0 );
}, args => 2, export => 1;

build_refute unlike => sub {
    _like_unlike( $_[0], $_[1], 1 );
}, args => 2, export => 1;

sub _like_unlike {
    my ($str, $reg, $reverse) = @_;

    $reg = qr#^(?:$reg)$# unless ref $reg eq 'Regexp';
        # retain compatibility with Test::More
    return 'unexpected undef' if !defined $str;
    return '' if $str =~ $reg xor $reverse;
    return "$str\n".($reverse ? "unexpectedly matches" : "doesn't match")."\n$reg";
};

=head2 can_ok

=cut

build_refute can_ok => sub {
    my $class = shift;

    croak ("can_ok(): no methods to check!")
        unless @_;

    return 'undefined' unless defined $class;
    return 'Not an object: '.to_scalar($class)
        unless UNIVERSAL::can( $class, "can" );

    my @missing = grep { !$class->can($_) } @_;
    return @missing && (to_scalar($class, 0)." has no methods ".join ", ", @missing);
}, no_pop => 1, export => 1;

=head2 isa_ok

=cut

build_refute isa_ok => \&_isa_ok, args => 2, export => 1;

build_refute new_ok => sub {
    my ($class, $args, $target) = @_;

    $args   ||= [];
    $class  = ref $class || $class;
    $target ||= $class;

    return "Not a class: ".to_scalar($class, 0)
        unless UNIVERSAL::can( $class, "can" );
    return "Class has no 'new' method: ".to_scalar( $class, 0 )
        unless $class->can( "new" );

    return _isa_ok( $class->new( @$args ), $target );
}, no_pop => 1, export => 1;

sub _isa_ok {
    my ($obj, $class) = @_;

    croak 'isa_ok(): No class supplied to check against'
        unless defined $class;
    return "undef is not a $class" unless defined $obj;
    $class = ref $class || $class;

    if (
        (UNIVERSAL::can( $obj, "isa" ) && !$obj->isa( $class ))
        || !UNIVERSAL::isa( $obj, $class )
    ) {
        return to_scalar( $obj, 0 ) ." is not a $class"
    };
    return '';
};

1;
