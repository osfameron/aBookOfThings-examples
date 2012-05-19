package TimerServer::Schema::Result::User;

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 NAME

TimerServer::Schema::Result::User

=cut

__PACKAGE__->table("users");

__PACKAGE__->load_components(qw/ EncodedColumn /);

__PACKAGE__->add_columns(
    id => { 
        data_type         => "integer", 
        is_auto_increment => 1, 
        is_nullable       => 0,
    },
    email => {
        data_type   => "text", 
        is_nullable => 0,
    },
    mac => {
        data_type   => "text", 
        is_nullable => 1,
    },
    password => {
        data_type     => 'char',
        size          => 22,
        encode_column => 1,
        encode_class  => 'Digest',
        encode_args   => {algorithm => 'MD5', format => 'base64'},
        encode_check_method => 'check_password',
    }
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint(["email"]);
__PACKAGE__->add_unique_constraint(["mac"]);

__PACKAGE__->has_many( timers => 'TimerServer::Schema::Result::Timer',
    { 'foreign.user_id' => 'me.id' });

1;
