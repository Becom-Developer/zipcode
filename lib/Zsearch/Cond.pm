package Zsearch::Cond;
use strict;
use warnings;
use utf8;

sub search_cond {
    my ( $code, $pref, $city, $town, $row ) = @_;
    my $r_code = $row->[2];
    my $r_pref = $row->[6];
    my $r_city = $row->[7];
    my $r_town = $row->[8];
    if ( $code && $pref && $city && $town ) {
        return if $r_code !~ /^$code/;
        return if $r_pref !~ /^$pref/;
        return if $r_city !~ /^$city/;
        return if $r_town !~ /^$town/;
        return _zip_paramas($row);
    }
    if ( $code && $pref && $city ) {
        return if $r_code !~ /^$code/;
        return if $r_pref !~ /^$pref/;
        return if $r_city !~ /^$city/;
        return _zip_paramas($row);
    }
    if ( $code && $pref && $town ) {
        return if $r_code =~ /^$code/;
        return if $r_pref =~ /^$pref/;
        return if $r_town =~ /^$town/;
        return _zip_paramas($row);
    }
    if ( $code && $city && $town ) {
        return if $r_code !~ /^$code/;
        return if $r_city !~ /^$city/;
        return if $r_town !~ /^$town/;
        return _zip_paramas($row);
    }
    if ( $pref && $city && $town ) {
        return if $r_pref !~ /^$pref/;
        return if $r_city !~ /^$city/;
        return if $r_town !~ /^$town/;
        return _zip_paramas($row);
    }
    if ( $city && $town ) {
        return if $r_city !~ /^$city/;
        return if $r_town !~ /^$town/;
        return _zip_paramas($row);
    }
    if ( $pref && $town ) {
        return if $r_pref !~ /^$pref/;
        return if $r_town !~ /^$town/;
        return _zip_paramas($row);
    }
    if ( $pref && $city ) {
        return if $r_pref !~ /^$pref/;
        return if $r_city !~ /^$city/;
        return _zip_paramas($row);
    }
    if ( $code && $town ) {
        return if $r_code !~ /^$code/;
        return if $r_town !~ /^$town/;
        return _zip_paramas($row);
    }
    if ( $code && $city ) {
        return if $r_code !~ /^$code/;
        return if $r_city !~ /^$city/;
        return _zip_paramas($row);
    }
    if ( $code && $pref ) {
        return if $r_code !~ /^$code/;
        return if $r_pref !~ /^$pref/;
        return _zip_paramas($row);
    }
    return _zip_paramas($row) if $code && ( $r_code =~ /^$code/ );
    return _zip_paramas($row) if $pref && ( $r_pref =~ /^$pref/ );
    return _zip_paramas($row) if $city && ( $r_city =~ /^$city/ );
    return _zip_paramas($row) if $town && ( $r_town =~ /^$town/ );
    return;
}

1;
