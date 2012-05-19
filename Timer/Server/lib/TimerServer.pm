package TimerServer;
use Dancer ':syntax';
use Dancer::Plugin::DBIC;
use Dancer::Plugin::REST;
use Dancer::Serializer::Text;

our $VERSION = '0.1';

prepare_serializer_for_format;
set session => 'YAML';


sub get_user_from_session {
    my $user_id = session('user_id');
    if ($user_id) {
        return schema->resultset('User')->find($user_id);
    }
}
sub require_session {
    get_user_from_session
        or halt('Not authorized');
}
sub require_user {
    my $user = get_user_from_session || do {
        if (my $mac = param 'mac') {
            schema->resultset('User')
                ->find({ mac => $mac });
        }
    };
    halt('Not authorized') unless $user;
    return $user;
}

get '/' => sub {
    template 'index';
};

sub create_user {
    my $username = param 'user';
    my $password = param 'pass';

    if (schema->resultset('User')->find({ email => $username })) {
        return status_bad_request({ 
            status=>'error', 
            message=>'Duplicate user', 
        });
    }
    else {
        my $user = schema->resultset('User')->create({
            email    => $username,
            password => $password,
        });
        return status_created({ 
            status=>'ok', 
            id => $user->id, 
        });
    }
}
post "/user.:format" => \&create_user;
post "/user"         => \&create_user;

post "/login.:format" => \&login;
post "/login"         => \&login;
sub login {
    my $username = param 'user';
    my $password = param 'pass';
    my $user = schema->resultset('User')->find({ email => $username });

    if ($user && $user->check_password($password)) {
        session user_id => $user->id;
        return status_ok({ 
            status=>'ok', 
            message=>'Login OK', 
        });
    }
    else {
        return status_bad_request({ 
            status=>'error', 
            message=>'Bad username or password',
        });
    }
}

post "/timer.:format" => \&create_timer;
post "/timer"         => \&create_timer;
sub create_timer {
    my $user = require_user;
    my $minutes = param 'minutes' or return status_bad_request({
        status => 'error',
        message => 'No minutes passed',
    });
    my $timer = schema->resultset('Timer')->create({
        user_id => $user->id,
        minutes => $minutes,
        status  => 'S', # started
    });
    return status_created({ 
        status=>'ok', 
        id => $timer->id, 
    });
}

get "/timer/:id.:format" => \&get_timer;
get "/timer/:id"         => \&get_timer;
sub get_timer {
    my $user = require_session;
    my $id = param 'id';
    if ($id) {
        my $timer = $user->timers->find($id);
        if ($timer) {
            return status_ok({
                status => 'ok',
                timer => $timer->serialize,
            });
        }
    }
    return status_not_found("Timer doesn't exist");
}

get "/timer.:format" => \&get_timers;
get "/timer"         => \&get_timers;
sub get_timers {
    my $user = require_session;
    return status_ok({
        status => 'ok',
        timers => [ map $_->serialize, $user->timers ],
    });
}

# API

true;
