package TimerServer;
use Dancer ':syntax';
use Dancer::Plugin::DBIC;
use Dancer::Plugin::REST;
use Dancer::Serializer::Text;

our $VERSION = '0.1';

prepare_serializer_for_format;
set session => 'YAML';


sub require_session {
    halt('Not logged in') unless session('user');
}

get '/' => sub {
    template 'index';
};

resource 'user' => (
    create => sub {
        my $username = param 'user';
        my $password = param 'pass';

        if (schema->resultset('User')->find({ email => $username })) {
            status_bad_request({ status=>'error', message=>'Duplicate user' });
        }
        else {
            my $user = schema->resultset('User')->create({
                email    => $username,
                password => $password,
            });
            session user => $user;
            status_created({ status=>'ok', id => $user->id });
        }
    },
);

resource 'login' => (
    post => sub {
        my $username = param 'user';
        my $password = param 'pass';
        if (my $user = schema->resultset('User')->find({ email => $username })) {
            if ($user->check_password($password)) {
                session user => $user;
                return status_ok({ status=>'ok', message=>'Login OK' });
            }
        }
        status_bad_request({ status=>'error', message=>'Bad username or password'});
    },
);

# API

# TODO, this should be added to a subclass of ::REST
BEGIN { no warnings 'redefine';
sub resource {
    my ($resource, %triggers) = @_;
 
    if (my $get = $triggers{get}) {
        get "/${resource}/:id.:format" => $get;
        get "/${resource}/:id"         => $get;
    }
    if (my $put = $triggers{update} || $triggers{put}) {
        put "/${resource}/:id.:format" => $put;
        put "/${resource}/:id"         => $put;
    }
    if (my $post = $triggers{create} || $triggers{post} ) {
        post "/${resource}.:format" => $post;
        post "/${resource}"         => $post;
    }
    if (my $del = $triggers{delete} || $triggers{del} ) {
        del "/${resource}/:id.:format" => $del;
        del "/${resource}/:id"         => $del;
    }
}}

true;
