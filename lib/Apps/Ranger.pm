package Apps::Ranger;

use strict;
use warnings;

our $VERSION = '0.01';

use base 'Apps::GENRanger';
use VMware::VIRuntime;


##-----------------------------------------------------------------
## $self->init( $r )
##-----------------------------------------------------------------
sub init {
    my ( $self, $req ) = @_;
    
    # process SUPER's init code
    $self->SUPER::init( $req );
    
    Vim::login(
        service_url => $self->service_url,
        user_name   => $self->username,
        password    => $self->password,
    );
    Vim::save_session( session_file => $self->session_file );
    
} # END init

#-----------------------------------------------------------------
# $self->do_main(  )
#-----------------------------------------------------------------
# This method inherited from Apps::GENRanger

#-----------------------------------------------------------------
# $self->site_links(  )
#-----------------------------------------------------------------
# This method inherited from Apps::GENRanger

1;

=head1 NAME

Apps::Ranger - the base module of this web app

=head1 SYNOPSIS

This package is meant to be used in a stand alone server/CGI script or the
Perl block of an httpd.conf file.

Stand Alone Server or CGI script:

    use Apps::Ranger;

    my $cgi = Gantry::Engine::CGI->new( {
        config => {
            #...
        },
        locations => {
            '/' => 'Apps::Ranger',
            #...
        },
    } );

httpd.conf:

    <Perl>
        # ...
        use Apps::Ranger;
    </Perl>

If all went well, one of these was correctly written during app generation.

=head1 DESCRIPTION

This module was originally generated by Bigtop.  But feel free to edit it.
You might even want to describe the table this module controls here.

=head1 METHODS

=over 4

=item get_orm_helper


=back


=head1 METHODS INHERITED FROM Apps::GENRanger

=over 4

=item namespace

=item init

=item do_main

=item site_links

=item schema_base_class


=back


=head1 SEE ALSO

    Gantry
    Apps::GENRanger
    Apps::Ranger::Inventory

=head1 AUTHOR

root, E<lt>root@localdomainE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 root

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.6 or,
at your option, any later version of Perl 5 you may have available.

=cut