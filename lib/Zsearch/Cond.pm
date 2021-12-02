package Zsearch::Cond;
use parent 'Zsearch';
use Zsearch::Format;
use strict;
use warnings;
use utf8;
sub format { return Zsearch::Format->new; }

sub refined_search {
    my ( $self, $cond, $row ) = @_;
    my $code   = $cond->{code};
    my $pref   = $cond->{pref};
    my $city   = $cond->{city};
    my $town   = $cond->{town};
    my $r_code = $row->[2];
    my $r_pref = $row->[6];
    my $r_city = $row->[7];
    my $r_town = $row->[8];

    if ( $code && $pref && $city && $town ) {
        return if $r_code !~ /^$code/;
        return if $r_pref !~ /^$pref/;
        return if $r_city !~ /^$city/;
        return if $r_town !~ /^$town/;
        return $self->format->zipcode($row);
    }
    if ( $code && $pref && $city ) {
        return if $r_code !~ /^$code/;
        return if $r_pref !~ /^$pref/;
        return if $r_city !~ /^$city/;
        return $self->format->zipcode($row);
    }
    if ( $code && $pref && $town ) {
        return if $r_code =~ /^$code/;
        return if $r_pref =~ /^$pref/;
        return if $r_town =~ /^$town/;
        return $self->format->zipcode($row);
    }
    if ( $code && $city && $town ) {
        return if $r_code !~ /^$code/;
        return if $r_city !~ /^$city/;
        return if $r_town !~ /^$town/;
        return $self->format->zipcode($row);
    }
    if ( $pref && $city && $town ) {
        return if $r_pref !~ /^$pref/;
        return if $r_city !~ /^$city/;
        return if $r_town !~ /^$town/;
        return $self->format->zipcode($row);
    }
    if ( $city && $town ) {
        return if $r_city !~ /^$city/;
        return if $r_town !~ /^$town/;
        return $self->format->zipcode($row);
    }
    if ( $pref && $town ) {
        return if $r_pref !~ /^$pref/;
        return if $r_town !~ /^$town/;
        return $self->format->zipcode($row);
    }
    if ( $pref && $city ) {
        return if $r_pref !~ /^$pref/;
        return if $r_city !~ /^$city/;
        return $self->format->zipcode($row);
    }
    if ( $code && $town ) {
        return if $r_code !~ /^$code/;
        return if $r_town !~ /^$town/;
        return $self->format->zipcode($row);
    }
    if ( $code && $city ) {
        return if $r_code !~ /^$code/;
        return if $r_city !~ /^$city/;
        return $self->format->zipcode($row);
    }
    if ( $code && $pref ) {
        return if $r_code !~ /^$code/;
        return if $r_pref !~ /^$pref/;
        return $self->format->zipcode($row);
    }
    return $self->format->zipcode($row) if $code && ( $r_code =~ /^$code/ );
    return $self->format->zipcode($row) if $pref && ( $r_pref =~ /^$pref/ );
    return $self->format->zipcode($row) if $city && ( $r_city =~ /^$city/ );
    return $self->format->zipcode($row) if $town && ( $r_town =~ /^$town/ );
    return;
}

1;
