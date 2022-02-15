package Zsearch::Command;
use parent 'Zsearch';
use strict;
use warnings;
use utf8;
use Encode qw(encode decode);
use Data::Dumper;
use Getopt::Long qw(GetOptionsFromArray);
use JSON::PP;
use Zsearch::Render;
sub render { return Zsearch::Render->new; }

sub hello { print "hello Command-----\n"; }

sub run {
    my ( $self, @args ) = @_;
    my ( $path, $method, $params ) = ( '', '', '{}' );
    my ( $code, $pref, $city, $town ) = ( '', '', '', '' );
    my ($output) = ('');
    GetOptionsFromArray(
        \@args,
        "path=s"   => \$path,
        "method=s" => \$method,
        "code=s"   => \$code,
        "pref=s"   => \$pref,
        "city=s"   => \$city,
        "town=s"   => \$town,
        "output=s" => \$output,
        "params=s" => \$params,
    ) or die("Error in command line arguments\n");
    my $opt = +{
        path   => decode( 'UTF-8', $path ),
        method => decode( 'UTF-8', $method ),
        params => decode_json($params),
        code   => decode( 'UTF-8', $code ),
        pref   => decode( 'UTF-8', $pref ),
        city   => decode( 'UTF-8', $city ),
        town   => decode( 'UTF-8', $town ),
        output => decode( 'UTF-8', $output ),
    };

    # 初期設定 / データベース設定更新 build
    if ( $opt->{path} eq 'build' ) {
        $self->render->to_json( $self->build->start($opt) );
        return;
    }

    # sql 検索
    if ( $opt->{code} || $opt->{pref} || $opt->{city} || $opt->{town} ) {
        if ( $opt->{output} eq 'simple' ) {
            $self->render->to_simple( $self->sql->run($opt) );
            return;
        }
        $self->render->to_json( $self->sql->run($opt) );
        return;
    }
    return $self->error->output(
        "The path is specified incorrectly: $opt->{path}");
}

1;

__END__
