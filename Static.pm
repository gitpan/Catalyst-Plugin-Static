package Catalyst::Plugin::Static;

use strict;
use base 'Class::Data::Inheritable';
use File::MMagic;
use File::Slurp;

our $VERSION = '0.01';

__PACKAGE__->mk_classdata('mmagic');
__PACKAGE__->mmagic( File::MMagic->new );

=head1 NAME

Catalyst::Plugin::Static - Serve static files with Catalyst

=head1 SYNOPSIS

    use Catalyst 'Static';

    $c->serve_static;

=head1 DESCRIPTION

Serve static files from config->{root}.

=head2 METHODS

=head3 serve_static

=cut

sub serve_static {
    my $c    = shift;
    my $path = $c->config->{root} . '/' . $c->req->path;
    if ( -f $path ) {
        my $content = read_file($path);
        my $type    = __PACKAGE__->mmagic->checktype_contents($content);
        $c->res->headers->content_type($type);
        $c->res->output($content);
        $c->log->debug(qq/Serving file "$path" as "$type"/) if $c->debug;
        return 1;
    }
    return 0;
}

=head1 SEE ALSO

L<Catalyst>.

=head1 AUTHOR

Sebastian Riedel, C<sri@cpan.org>

=head1 COPYRIGHT

This program is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;
