package Zsearch;
use strict;
use warnings;
use utf8;
use Zsearch::Build;
use Zsearch::CGI;
use Zsearch::CLI;
use Zsearch::DB;
use Zsearch::Error;
use Zsearch::Helper;
use Zsearch::Render;
use Zsearch::SearchSQL;
sub new    { bless {}, shift; }
sub build  { Zsearch::Build->new; }
sub CGI    { Zsearch::CGI->new; }
sub CLI    { Zsearch::CLI->new; }
sub DB     { Zsearch::DB->new; }
sub error  { Zsearch::Error->new; }
sub helper { Zsearch::Helper->new; }
sub render { Zsearch::Render->new; }
sub sql    { Zsearch::SearchSQL->new; }

1;

__END__
