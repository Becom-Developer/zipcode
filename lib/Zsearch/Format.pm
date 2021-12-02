package Zsearch::Format;
use parent 'Zsearch';
use strict;
use warnings;
use utf8;

sub zipcode {
    my ( $self, $row, $type ) = @_;
    return $row if ( $type && ( $type eq 'json' ) );
    return +{
        local_code         => $row->[0],
        zipcode_old        => $row->[1],
        zipcode            => $row->[2],
        pref_kana          => $row->[3],
        city_kana          => $row->[4],
        town_kana          => $row->[5],
        pref               => $row->[6],
        city               => $row->[7],
        town               => $row->[8],
        double_zipcode     => $row->[10],
        town_display       => $row->[11],
        city_block_display => $row->[12],
        double_town        => $row->[13],
        update_zipcode     => $row->[14],
        update_reason      => $row->[15],
    };
}

1;
