use strict;
use warnings;

use Test::More tests => 7;

use_ok( 'Apps::Ranger' );
use_ok( 'Apps::Ranger::Inventory' );
use_ok( 'Apps::Ranger::VMware' );
use_ok( 'Apps::Ranger::VMware::ESX' );
use_ok( 'Apps::Ranger::VMware::VM' );
use_ok( 'Apps::Ranger::VMware::Pool' );
use_ok( 'Apps::Ranger::VMware::Datacenter' );
