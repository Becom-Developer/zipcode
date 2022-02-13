package Zsearch::Error;
use parent 'Zsearch';
use strict;
use warnings;
use utf8;
use JSON::PP;

sub output {
    my ( $self, @args ) = @_;
    my $msg = shift @args;
    print encode_json { error => $msg };
    print "\n";
    return;
}

sub commit {
    my ( $self, @args ) = @_;
    my $msg = shift @args;
    return { error => $msg };;
}

1;

__END__

{
  "error": {
    "message": "The app with id {appId} " エラーメッセージ
  }
}
