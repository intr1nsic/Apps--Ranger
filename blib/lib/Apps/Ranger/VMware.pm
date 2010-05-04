package Apps::Ranger::VMware;

use strict;
use warnings;

use base 'Apps::Ranger';
use VMware::VIRuntime;
use VMware::VICredStore;
use File::stat;
use Time::localtime;
use Carp;

use Data::Dumper qw(
    Dumper
);

#-----------------------------------------------------------------
# $self->new()
#-----------------------------------------------------------------
sub new {
    my ( $class, $service_url, $session_path, $credstore_path,
        $username, $password ) = @_;
    
    my $self = {};

    croak 'No service url given'    if ( ! $service_url );
    croak 'No session path given'   if ( ! $session_path );
    croak 'No credstore path given' if ( ! $credstore_path );
    croak 'No username given'       if ( ! $username );
    croak 'No password given'       if ( ! $password );
    
    $self->{service_url} = $service_url;
    $self->{session_path} = $session_path;
    $self->{credstore_path} = $credstore_path;
    $self->{username} = $username,
    $self->{password} = $password,

    bless( $self, $class );

    VMware::VICredStore::init( filename => $self->{credstore_path} )
        or die( "Error: Unable to initialize the credential store" );
    
    $self->{session_file} = $self->{session_path} . "vmware_session_" . $self->{username};
    
    if( ! -e $self->{session_file} ) {
        $self->_create_session();
        return $self;
    }
    else {
        my $timestamp = stat($self->{session_file})->mtime + 600;
        if( $timestamp > time() ) {
            $self->_load_session();
            return $self;
        } else {
            $self->_create_session();
            return $self;
        }
    }

    return ( $self );
}

#-----------------------------------------------------------------
# $self->clear_store()
#-----------------------------------------------------------------
sub clear_store {
    my ( $self ) = @_;
    
    return $self->_remove_all_creds;
}

#-----------------------------------------------------------------
# $self->clear_store_for_user()
#-----------------------------------------------------------------
sub clear_store_for_user {
    my ( $self, $username ) = @_;
    
    return $self->_remove_creds( $username );
}

#-----------------------------------------------------------------
# $self->_create_session()
# param username
# param password
#-----------------------------------------------------------------
sub _create_session {
    my ( $self ) = @_;

    ( $self->{username}, $self->{password} ) = $self->_save_creds( 
                                                $self->{username}, 
                                                $self->{password}, );
    
    if( ! defined $self->{username} ) {
        die( "Error: There was an error creating the users creds in the store." );
    }
    
    Vim::login(
        service_url => $self->{service_url},
        user_name   => $self->{username},
        password    => $self->{password},
    );
    
    Vim::save_session( session_file => $self->{session_file} );
    return $self->_load_session( $self->{username} );

}

#-----------------------------------------------------------------
# $self->_load_session()
#-----------------------------------------------------------------
sub _load_session {
    my ( $self ) = @_;
    
    return Vim::load_session( session_file => $self->{session_file} );
}

#-----------------------------------------------------------------
# $self->_save_creds()
#-----------------------------------------------------------------
sub _save_creds {
    my ( $self, $username, $password ) = @_;

    # Store our users credentials in the datastore
    VMware::VICredStore::add_password(
                server      => $self->{service_url},
                username    => $username,
                password    => $password, 
            ); 
    
    return $self->_get_creds( $username );                    
}

#-----------------------------------------------------------------
# $self->_get_creds()
#-----------------------------------------------------------------
sub _get_creds {
    my ( $self, $username ) = @_;
        
    my $password = VMware::VICredStore::get_password(
        server      => $self->{service_url},
        username    => $username,
    );
    
    return ( $username, $password );    
}

#-----------------------------------------------------------------
# $self->_remove_creds()
#-----------------------------------------------------------------
sub _remove_creds {
    my ( $self, $username ) = @_;
    
    # Delete session file
    if( -e $self->{session_file} ) {
        unlink( $self->{session_file} );
    }

    # Remove the credentials
    VMware::VICredStore::remove_password(
            server      => $self->{service_url},
            username    => $username,
        );
    
    return 1;
}

#-----------------------------------------------------------------
# $self->_remove_all_creds()
#-----------------------------------------------------------------
sub _remove_all_creds {
    my ( $self ) = @_;
    
    return VMware::VICredStore::remove_passwords();
}

#-----------------------------------------------------------------
# $self->DESTROY()
#-----------------------------------------------------------------
sub DESTROY {
    VMware::VICredStore::close;
}

1;

=head1 NAME

Apps::Ranger::VMware - A controller in the Apps::Ranger application

=head1 SYNOPSIS

This package is meant to be used in a stand alone server/CGI script or the
Perl block of an httpd.conf file.

Stand Alone Server or CGI script:

    use Apps::Ranger::VMware;

    my $cgi = Gantry::Engine::CGI->new( {
        config => {
            #...
        },
        locations => {
            '/someurl' => 'Apps::Ranger::VMware',
            #...
        },
    } );

httpd.conf:

    <Perl>
        # ...
        use Apps::Ranger::VMware;
    </Perl>

    <Location /someurl>
        SetHandler  perl-script
        PerlHandler Apps::Ranger::VMware
    </Location>

If all went well, one of these was correctly written during app generation.

=head1 DESCRIPTION

This module was originally generated by Bigtop.  But feel free to edit it.
You might even want to describe the table this module controls here.

=head1 METHODS

=over 4

=item get_orm_helper


=back


=head1 DEPENDENCIES

    Apps::Ranger
    VMware::VIRuntime
    Data::Dumper

=head1 AUTHOR

root, E<lt>root@localdomainE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 root

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.6 or,
at your option, any later version of Perl 5 you may have available.

=cut
