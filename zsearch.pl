#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use Encode qw(encode decode);
for my $byte_text (@ARGV) {
    my $text     = decode( 'UTF-8', $byte_text );
    my $count    = length $text;
    my $msg      = "入力した文字: $text, 文字数: $count\n";
    my $byte_msg = encode( 'UTF-8', $msg );
    print $byte_msg;
}
my $path = './cpanfile';
open my $fh, '<', $path or die $!;
for my $lint (<$fh>) {
    print $lint;
}
