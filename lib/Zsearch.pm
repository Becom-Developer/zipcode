package Zsearch;
use strict;
use warnings;
use utf8;
use Zsearch::Error;
use Zsearch::CLI;
use Zsearch::CGI;
use Zsearch::Render;
use Zsearch::Helper;
use Zsearch::DB;

# class
sub new    { bless {}, shift; }
sub render { Zsearch::Render->new; }
sub error  { Zsearch::Error->new; }
sub CLI    { Zsearch::CLI->new; }
sub CGI    { Zsearch::CGI->new; }
sub helper { Zsearch::Helper->new; }
sub DB     { Zsearch::DB->new; }

1;

__END__
