package Catalyst::Plugin::Static;

use strict;
use base 'Class::Data::Inheritable';
use File::MimeInfo::Magic;
use File::Slurp;
use File::stat;
use NEXT;

our $VERSION = '0.05';


=head1 NAME

Catalyst::Plugin::Static - Serve static files with Catalyst

=head1 SYNOPSIS

    use Catalyst 'Static';

    # let File::MMagic determine the content type
    $c->serve_static;

    # or specify explicitly if you know better
    $c->serve_static('text/css');

=head1 DESCRIPTION

Serve static files from config->{root}.

=head2 METHODS

=head3 serve_static

=cut

sub finalize {
    my $c = shift;
    if ( $c->res->status =~ /^(1\d\d|[23]04)$/ ) {
        $c->res->headers->remove_content_headers;
        return $c->finalize_headers;
    }
    return $c->NEXT::finalize(@_);

}

sub serve_static {
    my $c    = shift;
    my $path = $c->config->{root} . '/' . $c->req->path;
    return $c->serve_static_file( $path, @_ );
}

sub serve_static_file {
    my $c    = shift;
    my $path = shift;
    
    if ( -f $path ) {

        my $stat = stat($path);

        if ( $c->req->headers->header('If-Modified-Since') ) {

            if ( $c->req->headers->if_modified_since == $stat->mtime ) {
                $c->res->status(304); # Not Modified
                $c->res->headers->remove_content_headers;
                return 1;
            }
        }

        my $type = shift || mimetype($path);
        my $content = read_file($path);
        $c->res->headers->content_type($type);
        $c->res->headers->content_length( $stat->size );
        $c->res->headers->last_modified( $stat->mtime );
        $c->res->output($content);
        $c->log->debug(qq/Serving file "$path" as "$type"/) if $c->debug;
        return 1;
    }

    $c->log->debug(qq/Failed to serve file "$path"/) if $c->debug;
    $c->res->status(404);

    return 0;
}

=head1 SEE ALSO

L<Catalyst>.

=head1 AUTHOR

Sebastian Riedel, C<sri@cpan.org>
Christian Hansen <ch@ngmedia.com>

=head1 THANK YOU

Torsten Seemann and all the others who've helped.

=head1 COPYRIGHT

This program is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;
