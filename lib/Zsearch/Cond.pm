package Zsearch::Cond;
use parent 'Zsearch';
use Zsearch::Format;
use strict;
use warnings;
use utf8;
sub format { return Zsearch::Format->new; }

sub refined_search {
    my ( $self, $cond, $row, $type ) = @_;
    my $code = $cond->{code};
    my $pref = $cond->{pref};
    my $city = $cond->{city};
    my $town = $cond->{town};
    my ( $r_code, $r_pref, $r_city, $r_town );
    if ( $type && ( $type eq 'json' ) ) {
        $r_code = $row->{zipcode};
        $r_pref = $row->{pref};
        $r_city = $row->{city};
        $r_town = $row->{town};
    }
    else {
        $r_code = $row->[2];
        $r_pref = $row->[6];
        $r_city = $row->[7];
        $r_town = $row->[8];
    }
    if ( $code && $pref && $city && $town ) {
        return if $r_code !~ /^$code/;
        return if $r_pref !~ /^$pref/;
        return if $r_city !~ /^$city/;
        return if $r_town !~ /^$town/;
        return $self->format->zipcode( $row, $type );
    }
    if ( $code && $pref && $city ) {
        return if $r_code !~ /^$code/;
        return if $r_pref !~ /^$pref/;
        return if $r_city !~ /^$city/;
        return $self->format->zipcode( $row, $type );
    }
    if ( $code && $pref && $town ) {
        return if $r_code !~ /^$code/;
        return if $r_pref !~ /^$pref/;
        return if $r_town !~ /^$town/;
        return $self->format->zipcode( $row, $type );
    }
    if ( $code && $city && $town ) {
        return if $r_code !~ /^$code/;
        return if $r_city !~ /^$city/;
        return if $r_town !~ /^$town/;
        return $self->format->zipcode( $row, $type );
    }
    if ( $pref && $city && $town ) {
        return if $r_pref !~ /^$pref/;
        return if $r_city !~ /^$city/;
        return if $r_town !~ /^$town/;
        return $self->format->zipcode( $row, $type );
    }
    if ( $city && $town ) {
        return if $r_city !~ /^$city/;
        return if $r_town !~ /^$town/;
        return $self->format->zipcode( $row, $type );
    }
    if ( $pref && $town ) {
        return if $r_pref !~ /^$pref/;
        return if $r_town !~ /^$town/;
        return $self->format->zipcode( $row, $type );
    }
    if ( $pref && $city ) {
        return if $r_pref !~ /^$pref/;
        return if $r_city !~ /^$city/;
        return $self->format->zipcode( $row, $type );
    }
    if ( $code && $town ) {
        return if $r_code !~ /^$code/;
        return if $r_town !~ /^$town/;
        return $self->format->zipcode( $row, $type );
    }
    if ( $code && $city ) {
        return if $r_code !~ /^$code/;
        return if $r_city !~ /^$city/;
        return $self->format->zipcode( $row, $type );
    }
    if ( $code && $pref ) {
        return if $r_code !~ /^$code/;
        return if $r_pref !~ /^$pref/;
        return $self->format->zipcode( $row, $type );
    }
    return $self->format->zipcode( $row, $type )
      if $code && ( $r_code =~ /^$code/ );
    return $self->format->zipcode( $row, $type )
      if $pref && ( $r_pref =~ /^$pref/ );
    return $self->format->zipcode( $row, $type )
      if $city && ( $r_city =~ /^$city/ );
    return $self->format->zipcode( $row, $type )
      if $town && ( $r_town =~ /^$town/ );
    return;
}

1;
