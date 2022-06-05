package Zsearch::CLI;
use parent 'Zsearch';
use strict;
use warnings;
use utf8;
use Encode qw(encode decode);
use Getopt::Long qw(GetOptionsFromArray);
use JSON::PP;

use Zsearch::SearchSQL;
use Zsearch::Build;
sub sql { Zsearch::SearchSQL->new; }
sub build { Zsearch::Build->new; }

sub run {
    my ( $self, @args ) = @_;
    my $resource = shift @args;
    my $method   = shift @args;
    return $self->error->output("Resource specification does not exist")
      if !$resource;
    return $self->error->output("Method specification does not exist")
      if !$method;
    my $params = '{}';
    GetOptionsFromArray( \@args, "params=s" => \$params, )
      or die("Error in command line arguments\n");
    my $opt = +{
        resource => decode( 'UTF-8', $resource ),
        method   => decode( 'UTF-8', $method ),
        params   => decode_json($params),
    };

    # 初期設定 / データベース設定更新 build
    if ( $opt->{resource} eq 'build' ) {
        $self->render->all_items_json( $self->build->start($opt) );
        return;
    }
    if ( $opt->{resource} eq 'search' ) {
        my $output = $self->sql->run($opt);
        if ( $opt->{params}->{output}
            && ( $opt->{params}->{output} eq 'simple' ) )
        {
            $self->render->simple($output);
            return;
        }
        $self->render->all_items_json($output);
        return;
    }
    return $self->error->output("The path is specified incorrectly");
}

1;

__END__
