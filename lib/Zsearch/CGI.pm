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

    # http header
    my $q = CGI->new();

    # cookieでapikeyを取得した場合はこちらで判定
    # apikeyのdbができてから実装
    # my $cookie_apikey = $query->cookie('apikey');

    my $origin  = $ENV{HTTP_ORIGIN};
    my @headers = (
        -type    => 'application/json',
        -charset => 'utf-8',
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
    my $opt      = {};
    my $postdata = $q->param('POSTDATA');
    if ($postdata) {
        $opt = decode_json($postdata);
    }

    # Validate
    return $self->error->output(
        "Unknown option specification: resource, method, apikey")
      if !$opt->{resource} || !$opt->{method} || !$opt->{apikey};
    return $self->error->output("apikey is incorrect: $opt->{apikey}")
      if $apikey ne $opt->{apikey};

    # Routing
    if ( $opt->{resource} eq 'search' ) {
        my $output = $self->sql->run($opt);
        $self->render->all_items_json($output);
        return;
    }
    return $self->error->output("The resource is specified incorrectly");
}

1;

__END__
