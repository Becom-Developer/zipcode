package Grecaptcha;
use strict;
use warnings;
use utf8;
use Pickup;
use JSON::PP;
use HTTP::Tiny;

sub new   { bless {}, shift; }
sub error { Pickup->new->error; }

sub run {
    my ( $self, @args ) = @_;
    my $options = shift @args;
    return $self->error->commit("No arguments") if !$options;
    return $self->_siteverify($options) if $options->{method} eq 'siteverify';
    return $self->error->commit(
        "Method not specified correctly: $options->{method}");
}

sub _siteverify {
    my ( $self, @args ) = @_;
    my $options = shift @args;
    my $params  = $options->{params};

    # 暫定でキーを書いておく
    my $default_secret = '6LcivDEjAAAAAOxO0_k4VwMJ4_rz6ZUnIXQQlRcX';
    my $url            = 'https://www.google.com/recaptcha/api/siteverify';

    # secret 指定がない時は設定済のキーを使う
    if ( exists $params->{secret} ) {
        $default_secret = $params->{secret};
    }
    my $req_params = +{
        secret   => $default_secret,
        response => $params->{response},
    };
    if ( exists $params->{remoteip} ) {
        $req_params->{remoteip} = $params->{remoteip};
    }

    # content の中は hash に変換できていなかった
    my $res     = HTTP::Tiny->new->post_form( $url, $req_params );
    my $content = decode_json( $res->{content} );
    $res->{content} = $content;
    return $res;
}

1;

__END__
