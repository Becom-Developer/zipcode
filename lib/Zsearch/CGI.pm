package Zsearch::CGI;
use parent 'Zsearch';
use strict;
use warnings;
use utf8;
use CGI;
use JSON::PP;
use Zsearch::Render;
sub render { return Zsearch::Render->new; }

sub run {
    my ( $self, @args ) = @_;
    my $apikey = 'becom';
    warn 'run--------1';

    # http header
    my $q      = CGI->new();
    my $origin = $ENV{HTTP_ORIGIN};

    my $cookie1 = $q->cookie(
        -name     => 'sessionID',
        -value    => 'xyzzy',
        -expires  => '+1h',
        -path     => '/',
        -domain   => '.becom.co.jp',
        -samesite => 'none',
        -secure   => 1
    );

    my $cookie2 = $q->cookie(
        -name     => 'sessionID2',
        -value    => 'xyzzyfooo',
        -expires  => '+1h',
        -path     => '/',
        -samesite => 'none',
        -secure   => 1
    );

    my $cookie3 = $q->cookie(
        -name     => 'sessionID3',
        -value    => 'xyzzybar',
        -expires  => '+1h',
        -domain   => 'mhj-web.becom.co.jp',
        -path     => '/',
        -samesite => 'none',
        -secure   => 1
    );

    my @headers = (
        -type    => 'application/json',
        -charset => 'utf-8',
        -cookie  => [ $cookie1, $cookie2, $cookie3 ],
    );
    if ($origin) {
        @headers = (
            @headers,
            -access_control_allow_origin  => $origin,
            -access_control_allow_headers => 'content-type,X-Requested-With',
            -access_control_allow_methods => 'GET,POST,OPTIONS',
            -access_control_allow_credentials => 'true',
        );
    }
    $self->render->raw( $q->header(@headers) );
    warn $self->dump( $q->header(@headers) );
    warn 'run-------2';
    my $opt      = {};
    my $postdata = $q->param('POSTDATA');
    if ($postdata) {
        $opt = decode_json($postdata);
    }
    warn 'run-------3';

    # Validate
    return $self->error->output(
        "Unknown option specification: path, method, apikey")
      if !$opt->{path} || !$opt->{method} || !$opt->{apikey};
    return $self->error->output("apikey is incorrect: $opt->{apikey}")
      if $apikey ne $opt->{apikey};

    # Routing
    if ( $opt->{path} eq 'search' ) {
        $self->render->all_items_json( $self->sql->run( $opt->{params} ) );
        return;
    }
    return $self->error->output("The path is specified incorrectly");
}

1;

__END__
