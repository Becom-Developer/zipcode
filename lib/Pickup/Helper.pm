package Pickup::Helper;
use parent 'Pickup::Base';
use strict;
use warnings;
use utf8;
use FindBin;
use File::Spec;
use Time::Piece;
use Data::Dumper;

sub dump {
    my ( $self, @args ) = @_;
    my $d = Data::Dumper->new( [ shift @args ] );
    return $d->Dump;
}
sub time_stamp { localtime->datetime( 'T' => ' ' ); }

sub is_test_mode {
    return if !$ENV{"ZSEARCH_MODE"};
    return if $ENV{"ZSEARCH_MODE"} ne 'test';
    return 1;
}

# file
sub home          { File::Spec->catfile( $FindBin::RealBin, '..' ); }
sub homedb        { File::Spec->catfile( home(),            'db' ); }
sub homebackup    { File::Spec->catfile( home(),            'backup' ); }
sub sql_file_path { File::Spec->catfile( home(),            'zsearch.sql' ); }

sub dump_file_path {
    return $ENV{"ZSEARCH_DUMP"} if $ENV{"ZSEARCH_DUMP"};
    return File::Spec->catfile( homebackup(), 'zsearch.dump' );
}

sub db_file_path {
    return $ENV{"ZSEARCH_DB"} if $ENV{"ZSEARCH_DB"};
    return File::Spec->catfile( homedb(), 'zsearch.db' );
}

1;

__END__
