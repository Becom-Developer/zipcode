package Zsearch::Cond;
use parent 'Zsearch';
use Zsearch::Format;
use strict;
use warnings;
use utf8;
sub format { return Zsearch::Format->new; }

# 0 文字は検索対象にしたい
sub _has_value {
    my ( $self, $val ) = @_;
    return 0 if !defined $val;
    return 0 if $val eq '';
    return 1;
}

# 検索対象のデータ項目が変わることがある
sub _target_val {
    my ( $self, $type, $row ) = @_;
    my $r = +{};
    if ( $type && ( $type eq 'json' ) ) {
        $r->{code} = $row->{zipcode};
        $r->{pref} = $row->{pref};
        $r->{city} = $row->{city};
        $r->{town} = $row->{town};
        return $r;
    }
    $r->{code} = $row->[2];
    $r->{pref} = $row->[6];
    $r->{city} = $row->[7];
    $r->{town} = $row->[8];
    return $r;
}

sub refined_search {
    my ( $self, $cond, $row, $type ) = @_;
    my $code     = $cond->{code};
    my $pref     = $cond->{pref};
    my $city     = $cond->{city};
    my $town     = $cond->{town};
    my $has_code = $self->_has_value($code);
    my $has_pref = $self->_has_value($pref);
    my $has_city = $self->_has_value($city);
    my $has_town = $self->_has_value($town);
    my $r        = $self->_target_val( $type, $row );

    if ( $has_code && $has_pref && $has_city && $has_town ) {
        return if $r->{code} !~ /^$code/;
        return if $r->{pref} !~ /^$pref/;
        return if $r->{city} !~ /^$city/;
        return if $r->{town} !~ /^$town/;
        return $self->format->zipcode( $row, $type );
    }
    if ( $has_code && $has_pref && $has_city ) {
        return if $r->{code} !~ /^$code/;
        return if $r->{pref} !~ /^$pref/;
        return if $r->{city} !~ /^$city/;
        return $self->format->zipcode( $row, $type );
    }
    if ( $has_code && $has_pref && $has_town ) {
        return if $r->{code} !~ /^$code/;
        return if $r->{pref} !~ /^$pref/;
        return if $r->{town} !~ /^$town/;
        return $self->format->zipcode( $row, $type );
    }
    if ( $has_code && $has_city && $has_town ) {
        return if $r->{code} !~ /^$code/;
        return if $r->{city} !~ /^$city/;
        return if $r->{town} !~ /^$town/;
        return $self->format->zipcode( $row, $type );
    }
    if ( $has_pref && $has_city && $has_town ) {
        return if $r->{pref} !~ /^$pref/;
        return if $r->{city} !~ /^$city/;
        return if $r->{town} !~ /^$town/;
        return $self->format->zipcode( $row, $type );
    }
    if ( $has_city && $has_town ) {
        return if $r->{city} !~ /^$city/;
        return if $r->{town} !~ /^$town/;
        return $self->format->zipcode( $row, $type );
    }
    if ( $has_pref && $has_town ) {
        return if $r->{pref} !~ /^$pref/;
        return if $r->{town} !~ /^$town/;
        return $self->format->zipcode( $row, $type );
    }
    if ( $has_pref && $has_city ) {
        return if $r->{pref} !~ /^$pref/;
        return if $r->{city} !~ /^$city/;
        return $self->format->zipcode( $row, $type );
    }
    if ( $has_code && $has_town ) {
        return if $r->{code} !~ /^$code/;
        return if $r->{town} !~ /^$town/;
        return $self->format->zipcode( $row, $type );
    }
    if ( $has_code && $has_city ) {
        return if $r->{code} !~ /^$code/;
        return if $r->{city} !~ /^$city/;
        return $self->format->zipcode( $row, $type );
    }
    if ( $has_code && $has_pref ) {
        return if $r->{code} !~ /^$code/;
        return if $r->{pref} !~ /^$pref/;
        return $self->format->zipcode( $row, $type );
    }
    return $self->format->zipcode( $row, $type )
      if $has_code && ( $r->{code} =~ /^$code/ );
    return $self->format->zipcode( $row, $type )
      if $has_pref && ( $r->{pref} =~ /^$pref/ );
    return $self->format->zipcode( $row, $type )
      if $has_city && ( $r->{city} =~ /^$city/ );
    return $self->format->zipcode( $row, $type )
      if $has_town && ( $r->{town} =~ /^$town/ );
    return;
}

1;

__END__

条件まとめ
code, pref, city, town
code, pref, city
code, pref,       town
code,       city, town
      pref, city, town
            city, town
      pref,       town
      pref, city
code,             town
code,       city
code, pref
code,
      pref
            city
                  town

code 必須
code, pref, city, town
code, pref, city
code, pref,       town
code,       city, town
code, pref
code,       city
code,             town
code,

pref 必須
code, pref, city, town
      pref, city, town
code, pref,       town
code, pref, city,
      pref,       town
code, pref
      pref, city
      pref

city 必須
code, pref, city, town
      pref, city, town
code,       city, town
code, pref, city
            city, town
code,       city
      pref, city
            city

town 必須
code, pref, city, town
      pref, city, town
code,       city, town
code, pref,       town
            city, town
code,             town
      pref,       town
                  town
