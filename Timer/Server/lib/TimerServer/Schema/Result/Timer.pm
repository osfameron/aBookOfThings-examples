package TimerServer::Schema::Result::Timer;

use strict; use warnings;

use base 'DBIx::Class::Core';

=head1 NAME

TimerServer::Schema::Result::Timer

=cut

__PACKAGE__->table("timers");

__PACKAGE__->load_components(qw/TimeStamp InflateColumn::DateTime/);
__PACKAGE__->add_columns(
    id => { 
        data_type         => "integer", 
        is_auto_increment => 1, 
        is_nullable       => 0,
    },
    user_id => { 
        data_type   => "integer", 
        is_nullable => 0,
    },
    description => {
        data_type   => "text", 
        is_nullable => 1,
    },
    start_datetime => {
        data_type     => "datetime", 
        set_on_create => 1,
        is_nullable   => 0,
    },
    "duration" => { 
        data_type => "integer", 
        is_nullable => 0,
    },
    "end_datetime" => {
        data_type   => "datetime", 
        is_nullable => 1,
    },
    "status" => {
        data_type   => "text",
        length      => 1,
        is_nullable => 0,
    },
);

__PACKAGE__->set_primary_key("id");
__PACKAGE__->belongs_to( user => 'TimerServer::Schema::Result::User',
    { 'foreign.id' => 'self.user_id' });

sub is_open {
    my $self = shift;
    return $self->status eq 'S'; # started
}

sub serialize {
    my $self = shift;
    return { $self->get_columns };
}

1;
