package TestApp;

use Catalyst qw[Static];
use File::Spec::Functions qw[catpath splitpath rel2abs];

__PACKAGE__->config(
    root => rel2abs( catpath( ( splitpath($0) )[0,1], '' ) )
);

__PACKAGE__->action(
    '!default' => sub {
        my ( $self, $c ) = @_;
        $c->serve_static;
    }
);

package main;

use Test::More tests => 10;
use Catalyst::Test 'TestApp';
use File::stat;
use File::Slurp;
use HTTP::Date;

my $stat = stat($0);

{
    ok( my $response = request('/02static.t'),        'Request'                   );
    ok( $response->code == 200,                       'OK status code'            );
    ok( $response->content_length == $stat->size,     'Content length'            );
    ok( $response->last_modified == $stat->mtime,     'Modified date'             );
    ok( $response->content eq read_file($0),          'Content'                   );
}

{
    local $ENV{HTTP_IF_MODIFIED_SINCE} = time2str($stat->mtime);

    ok( my $response = request('/02static.t'),        'If Modified Since request' );
    ok( $response->code == 304,                       'Not Modified status code'  );
    ok( $response->content eq '',                     'No content'                );
}

{
    ok( my $response = request('/non/existing/file'), 'Non existing uri request'  );
    ok( $response->code == 404,                       'Not Found status code'     );
}
