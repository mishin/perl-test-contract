package Test::Refute;

use 5.006;
use strict;
use warnings;
our $VERSION = '0.01';

=head1 NAME

Test::Refute - a lightweight unit-testing and assertion tool.

=head1 SYNOPSIS

=head1 EXPORT

All functions in this module are exported by default.

=head1 FUNCTIONS

=cut

use Carp;
use parent qw(Exporter);
our @EXPORT = (qw(done_testing note diag), @Test::Refute::Engine::Basic);

use Test::Refute::TAP;

sub import {
    $Test::Refute::Engine::Default = Test::Refute::TAP->new;
    goto &Exporter::import;
};

END {
    $Test::Refute::Engine::Default->{done}
         or croak "done_testing was not seen";

    my $ret = $Test::Refute::Engine::Default->errors;
    $ret = 100 if $ret > 100;
    $? = $ret;
};

foreach (@EXPORT) {
    my $name = $_;

    my $code = sub (@) {
        $Test::Refute::Engine::Default
            or croak "$name(): Not currently testing anything";
        $Test::Refute::Engine::Default->$name(@_);
    };

    no strict 'refs';
    *$name = $code;
};

=head1 AUTHOR

Konstantin S. Uvarin, C<< <khedin at gmail.com> >>

=head1 BUGS

This is alpha software, lots of bugs guaranteed.

Please report any bugs or feature requests to C<bug-test-refute at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Test-Refute>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Test::Refute

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Test-Refute>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Test-Refute>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Test-Refute>

=item * Search CPAN

L<http://search.cpan.org/dist/Test-Refute/>

=back

=head1 ACKNOWLEDGEMENTS

Karl Popper (the philosopher) inspired me to invert assertion into refutation.

=head1 LICENSE AND COPYRIGHT

Copyright 2016 Konstantin S. Uvarin.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


=cut

1; # End of Test::Refute
