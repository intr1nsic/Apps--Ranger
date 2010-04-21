use strict;
use warnings;

use Test::More tests => 4;

use Apps::Ranger qw{
    -Engine=CGI
    -TemplateEngine=TT
};

use Gantry::Server;
use Gantry::Engine::CGI;

# these tests must contain valid template paths to the core gantry templates
# and any application specific templates

my $cgi = Gantry::Engine::CGI->new( {
    config => {
        dbconn => 'dbi:SQLite:dbname=app.db',
        doc_rootp => '/static',
        password => 'password',
        service_url => 'https:///sdk/webService',
        session_file => '/tmp/vmware_session',
        show_dev_navigation => '1',
        template_wrapper => 'genwrapper.tt',
        username => 'username',
        root => 'html:html/templates',
    },
    locations => {
        '/' => 'Apps::Ranger',
        '/inventory' => 'Apps::Ranger::Inventory',
        '/vmware' => 'Apps::Ranger::VMware',
        '/vmware/esx' => 'Apps::Ranger::VMware::ESX',
    },
} );

my @tests = qw(
    /
    /inventory
    /vmware
    /vmware/esx
);

my $server = Gantry::Server->new();
$server->set_engine_object( $cgi );

SKIP: {

    eval {
        require DBD::SQLite;
    };
    skip 'DBD::SQLite is required for run tests.', 4 if ( $@ );

    unless ( -f 'app.db' ) {
        skip 'app.db sqlite database required for run tests.', 4;
    }

    foreach my $location ( @tests ) {
        my( $status, $page ) = $server->handle_request_test( $location );
        ok( $status eq '200',
                "expected 200, received $status for $location" );

        if ( $status ne '200' ) {
            print STDERR $page . "\n\n";
        }
    }

}
