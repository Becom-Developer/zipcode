package Zsearch::CLI;
use parent 'Zsearch';
use strict;
use warnings;
use utf8;
use Encode qw(encode decode);
use Data::Dumper;
use Getopt::Long;
use Text::CSV;

sub hello { print "hello CLI-----\n"; }

# オプションの設定
my ( $code, $pref, $city, $town ) = '';
my $path = './csv/40FUKUOK.CSV';
my $type = 'text';
GetOptions(
    "code=i" => \$code,
    "pref=s" => \$pref,
    "city=s" => \$city,
    "town=s" => \$town,
    "path=s" => \$path,
    "type=s" => \$type,
) or die("Error in command line arguments\n");

$code = decode( 'UTF-8', $code );
$pref = decode( 'UTF-8', $pref );
$city = decode( 'UTF-8', $city );
$town = decode( 'UTF-8', $town );

sub run {
    my ( $self, @args ) = @_;
    warn $path;
    warn $code;
    return;
}

1;
