#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use Encode qw(encode decode);
use Text::CSV;
for my $byte_text (@ARGV) {
    my $text     = decode( 'UTF-8', $byte_text );
    my $count    = length $text;
    my $msg      = "入力した文字: $text, 文字数: $count\n";
    my $byte_msg = encode( 'UTF-8', $msg );
    print $byte_msg;
}
my $path = './csv/40FUKUOK.CSV';

# open my $fh, '<', $path or die $!;
# for my $lint (<$fh>) {
#     print $lint;
# }

my @rows;
my $address;
# Read/parse CSV
my $csv = Text::CSV->new();
open my $fh, "<:encoding(utf8)", $path or die "test.csv: $!";
while ( my $row = $csv->getline($fh) ) {
    my $zipcode = $row->[2];
    if ($zipcode eq 8120041) {
        push @rows, $row;
    }
}

# my $byte_address = encode( 'UTF-8', @rows[0][0] );

# print $byte_address."\n";
close $fh;

