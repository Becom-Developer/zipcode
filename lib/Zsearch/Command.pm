package Zsearch::Command;
use parent 'Zsearch';
use strict;
use warnings;
use utf8;
use Encode qw(encode decode);
use Data::Dumper;
use Getopt::Long qw(GetOptionsFromArray);
use JSON::PP;

sub hello { print "hello Command-----\n"; }

sub run {
    my ( $self, @args ) = @_;
    my ( $path, $method, $params ) = ( '', '', '{}' );
    GetOptionsFromArray(
        \@args,
        "path=s"   => \$path,
        "method=s" => \$method,
        "params=s" => \$params
    ) or die("Error in command line arguments\n");
    my $options = +{
        path   => decode( 'UTF-8', $path ),
        method => decode( 'UTF-8', $method ),
        params => decode_json $params,
    };

    # 初期設定 / データベース設定更新 build
    if ( $options->{path} eq 'build' ) {
        print encode_json( $self->build->start($options) );
        print "\n";
        return;
    }

    return $self->error->output(
        "The path is specified incorrectly: $options->{path}");
}

1;

__END__
