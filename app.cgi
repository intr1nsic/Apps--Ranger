#!/usr/bin/perl
use strict;


use CGI::Carp qw( fatalsToBrowser );

use Apps::Ranger qw{
    -Engine=CGI
    -TemplateEngine=TT
};

use Gantry::Engine::CGI;

my $cgi = Gantry::Engine::CGI->new( {
    config => {
        GantryConfInstance => 'apps_ranger_CGI',
        GantryConfFile => '/etc/gantry.d/app.gantry.conf',
    },
    locations => {
        '/' => 'Apps::Ranger',
        '/inventory' => 'Apps::Ranger::Inventory',
        '/vmware' => 'Apps::Ranger::VMware',
        '/vmware/esx' => 'Apps::Ranger::VMware::ESX',
        '/vmware/vm' => 'Apps::Ranger::VMware::VM',
    },
} );

$cgi->dispatch();

if ( $cgi->{config}{debug} ) {
    foreach ( sort { $a cmp $b } keys %ENV ) {
        print "$_ $ENV{$_}<br />\n";
    }
}
