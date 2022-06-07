package Pickup;
use strict;
use warnings;
use utf8;
use Pickup::Error;
use Pickup::Helper;
use Pickup::Render;
sub new    { bless {}, shift; }
sub error  { Pickup::Error->new; }
sub helper { Pickup::Helper->new; }
sub render { Pickup::Render->new; }

1;

__END__
