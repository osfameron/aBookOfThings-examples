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
        my $user = return schema->resultset('User')->find($user_id);
        var user => $user;
        return $user;
    }
}
sub get_user_from_mac {
    if (my $mac = param 'mac') {
        my $user = schema->resultset('User')
            ->find({ mac => $mac });
         var user => $user;
         return $user;
    }
}
sub require_session {
    get_user_from_session
        or halt('Not authorized');
}
sub require_user {
    my $user = var('user')
        || get_user_from_session 
        || get_user_from_mac;
    halt('Not authorized') unless $user;
    return $user;
}
sub require_timer {
    my $timer = do {
        my $user = require_user;
        my $id = param 'id';
        if ($user && $id) {
            $user->timers->find($id);
        }
    };
    halt(status_not_found("Timer doesn't exist"))
        unless $timer;

    return $timer;
}
sub require_open_timer {
    my $timer = require_timer;
    return status_bad_request("Can't update timer unless open")
        unless $timer->is_open;
    return $timer;
}

get '/' => sub {
    template 'index';
};

#1
post "/timers.:format" => sub {
    my $user = require_user;
    my $duration = param 'duration' 
        or return status_bad_request('No duration passed');

    my $timer = schema->resultset('Timer')->create({
        user_id  => $user->id,
        duration => $duration,
        status   => 'S', # started
    });
    return status_created({ 
        status=>'ok', 
        id => $timer->id, 
    });
};

#2
put "/timers/:id/duration.:format" => {
    my $user = require_user;
    my $timer = require_open_timer;

    my $duration = param 'duration'
        or return update_complete;

    ## NB: the following calculation has to extend the time as of now

    my $start_datetime = $timer->start_datetime;
    my $new_end_time = DateTime->now->add( minutes => $duration );
    my $total_duration = ($new_end_time - $start_datetime)->in_units('minutes');

    $timer->update({ duration => $total_duration });

    return status_ok({
        ok => 1,
        message => 'Timer length updated',
    });
};

#3
put "/timers/:id/complete.:format" => sub {
    my $user = require_user;
    my $timer = require_open_timer;

    $timer->update({ status => 'C' });

    return status_ok({
        ok => 1,
        message => 'Timer marked complete',
    });
};

#4
del "/timers/:id.:format" => sub {
    my $user = require_user;
    my $timer = require_timer;
    $timer->update({ status => 'D' }); # or ->delete?
    return status_ok({
        status => 'ok',
    });
};

#5
put "/timers/:id/description.:format" => sub {
    my $user = require_session;
    my $timer = require_open_timer;
    my $description = param 'description';

    $timer->update({ description => $description });

    return status_ok({
        ok => 1,
        message => 'Description updated',
    });
};

#6
get "/timers.:format" => sub {
    my $user = require_session;
    return status_ok({
        status => 'ok',
        timers => [ map $_->serialize, $user->timers ],
    });
};

#7
get "/timers/:id.:format" => sub {
    my $user = require_session;
    my $timer = require_timer;
    return status_ok({
        status => 'ok',
        timer => $timer->serialize,
    });
};

#8 TODO

#9 TODO

#10
post "/login.:format" => sub {
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
        return status_bad_request("Bad username or password");
    }
};

#11
post "/user.:format" => sub {
    my $username = param 'user';
    my $password = param 'pass';

    if (schema->resultset('User')->find({ email => $username })) {
        return status_bad_request("Duplicate user");
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
};






# API

true;
