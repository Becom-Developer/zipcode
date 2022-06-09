package Zsearch;
use strict;
use warnings;
use utf8;
use Zsearch::Build;
use Zsearch::CGI;
use Zsearch::CLI;
use Zsearch::DB;
use Zsearch::SearchSQL;
use Pickup;
sub new    { bless {}, shift; }
sub build  { Zsearch::Build->new; }
sub CGI    { Zsearch::CGI->new; }
sub CLI    { Zsearch::CLI->new; }
sub DB     { Zsearch::DB->new; }
sub error  { Pickup->new->error; }
sub helper { Pickup->new->helper; }
sub render { Pickup->new->render; }
sub sql    { Zsearch::SearchSQL->new; }

1;

__END__
