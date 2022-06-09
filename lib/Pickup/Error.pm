package Pickup::Error;
use parent 'Pickup::Base';
use strict;
use warnings;
use utf8;
use Pickup::Render;
sub render { Pickup::Render->new; }

sub output {
    my ( $self, @args ) = @_;
    my $params = $self->commit( shift @args );
    $self->render->all_items_json($params);
    return;
}

sub commit {
    my ( $self, @args ) = @_;
    my $msg = shift @args;
    return { error => { message => $msg } };
}

1;

__END__

{
  "error": {
    "message": "Not specified correctly"
  }
}
