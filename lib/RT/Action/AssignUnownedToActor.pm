use strict;
use warnings;
package RT::Action::AssignUnownedToActor;

our $VERSION = '0.01';

use base qw(RT::Action);

sub Prepare {
    my $self = shift;

    # Only unowned tickets
    return 0 if $self->TicketObj->OwnerObj->id != RT->Nobody->id;

    # when the actor isn't RT_System
    my $actor = $self->TransactionObj->CreatorObj;
    return 0 if $actor->id == RT->SystemUser->id;

    # and the actor isn't a requestor
    return 0 if $self->TicketObj->Requestors->HasMember( $actor->id );

    # and the actor can own tickets
    return 0 unless $actor->PrincipalObj->HasRight(
        Object => $self->TicketObj,
        Right  => 'OwnTicket',
    );

    $self->{'set_owner_to'} = $actor->id;
    return 1;
}

sub Commit {
    my $self = shift;
    my $owner = $self->{'set_owner_to'};

    RT->Logger->debug("Setting owner to $owner");
    my ($ok, $msg) = $self->TicketObj->SetOwner( $owner );

    unless ($ok) {
        RT->Logger->error("Couldn't set owner to $owner: $msg");
        return 0;
    }
    return 1;
}

=head1 NAME

RT-Action-AssignUnownedToActor - Assigns unowned tickets to the transaction actor

=head1 DESCRIPTION

Assigns tickets to the actor of the transaction that triggered the
scrip, if all the conditions below are met:

=over 4

=item The ticket is owned by Nobody

=item The actor isn't RT_System

=item The actor isn't a requestor on the ticket

=item The actor has the right to own the ticket

=back

Note that this means the requestor will never be assigned as the owner
by this action.

=head1 INSTALLATION 

=over

=item perl Makefile.PL

=item make

=item make install

May need root permissions

=item make initdb

Only run this once or you'll end up with duplicate scrip actions.

=item Edit your /opt/rt4/etc/RT_SiteConfig.pm

Add this line:

    Set(@Plugins, qw(RT::Action::AssignUnownedToActor));

or add C<RT::Action::AssignUnownedToActor> to your existing C<@Plugins> line.

=item Clear your mason cache

    rm -rf /opt/rt4/var/mason_data/obj

=item Restart your webserver

=item Create an appropriate Scrip using this new action

=back

=head1 AUTHOR

Thomas Sibley <trs@bestpractical.com>

=head1 LICENCE AND COPYRIGHT

This software is copyright (c) 2011 by Best Practical Solutions.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.


=cut

1;
