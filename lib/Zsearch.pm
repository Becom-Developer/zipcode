package Zsearch;
use strict;
use warnings;
use utf8;
use FindBin;
use JSON::PP;
use Zsearch::Error;
use Zsearch::Build;
use Zsearch::SearchSQL;
use File::Spec;
use DBI;
use Time::Piece;
use Data::Dumper;
sub new           { bless {}, shift; }
sub error         { Zsearch::Error->new; }
sub build         { Zsearch::Build->new; }
sub sql           { Zsearch::SearchSQL->new; }
sub time_stamp    { localtime->datetime( 'T' => ' ' ); }
sub home          { $FindBin::RealBin; }
sub db_file_path  { File::Spec->catfile( home(), '..', 'db', db_file() ); }
sub db_dir_path   { File::Spec->catfile( home(), '..', 'db' ); }
sub sql_file_path { File::Spec->catfile( home(), '..', 'zsearch.sql' ); }

sub dump {
    my ( $self, @args ) = @_;
    my $d = Data::Dumper->new( [ shift @args ] );
    return $d->Dump;
}

sub insert_csv {
    my $file = File::Spec->catfile( home(), '..', 'csv', 'KEN_ALL.CSV' );
    if ( $ENV{"ZSEARCH_MODE"} && ( $ENV{"ZSEARCH_MODE"} eq 'test' ) ) {
        $file = File::Spec->catfile( home(), '..', 'csv', '40FUKUOK.CSV' );
    }
    return $file;
}

sub db_file {
    my $db_file = 'zsearch.db';
    if ( $ENV{"ZSEARCH_MODE"} && ( $ENV{"ZSEARCH_MODE"} eq 'test' ) ) {
        $db_file = 'zsearch-test.db';
    }
    return $db_file;
}

sub build_dbh {
    my ( $self, @args ) = @_;
    my $db   = $self->db_file_path;
    my $attr = +{
        RaiseError     => 1,
        AutoCommit     => 1,
        sqlite_unicode => 1,
    };
    my $dbh = DBI->connect( "dbi:SQLite:dbname=$db", "", "", $attr );
    return $dbh;
}

# $self->rows($table, \@cols, \%params);
sub rows {
    my ( $self, $table, $cols, $params ) = @_;
    my $sql_q = [];
    for my $col ( @{$cols} ) {
        push @{$sql_q}, qq{$col LIKE "$params->{$col}%"};
    }
    push @{$sql_q}, qq{deleted = 0};
    my $sql_clause = join " AND ", @{$sql_q};
    my $sql        = qq{SELECT * FROM $table WHERE $sql_clause};
    my $dbh        = $self->build_dbh;
    my $hash       = $dbh->selectall_hashref( $sql, 'id' );
    my $arrey_ref  = [];
    for my $key ( sort keys %{$hash} ) {
        push @{$arrey_ref}, $hash->{$key};
    }
    return $arrey_ref;
}

1;

__END__
