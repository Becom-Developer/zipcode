package Zsearch;
use strict;
use warnings;
use utf8;
use FindBin;
use JSON::PP;
use File::Spec;
use DBI;
use Time::Piece;
use Data::Dumper;
use Zsearch::Error;
use Zsearch::Build;
use Zsearch::SearchSQL;
use SQLite::Simple;

# class
sub new   { bless {}, shift; }
sub error { Zsearch::Error->new; }
sub build { Zsearch::Build->new; }
sub sql   { Zsearch::SearchSQL->new; }

# helper
sub time_stamp { localtime->datetime( 'T' => ' ' ); }

sub db {
    my ( $self, $args ) = @_;
    if ( !$args ) {
        $args = {};
    }
    my $simple = SQLite::Simple->new(
        {
            db_file_path   => $self->db_file_path,
            sql_file_path  => $self->sql_file_path,
            dump_file_path => $self->dump_file_path,
            %{$args},
        }
    );
    return $simple;
}

sub is_test_mode {
    return if !$ENV{"ZSEARCH_MODE"};
    return if $ENV{"ZSEARCH_MODE"} ne 'test';
    return 1;
}

sub dump {
    my ( $self, @args ) = @_;
    my $d = Data::Dumper->new( [ shift @args ] );
    return $d->Dump;
}

sub valid_single {
    my ( $self, $table, $params ) = @_;
    my $q_params = +{ %{$params}, deleted => 0, };
    return $self->db->single( $table, $q_params );
}

sub valid_search {
    my ( $self, $table, $params ) = @_;
    my $q_params = +{ %{$params}, deleted => 0, };
    return $self->db->search( $table, $q_params );
}

sub safe_insert {
    my ( $self, $table, $params ) = @_;
    my $dt = $self->time_stamp;
    my $insert_params =
      +{ %{$params}, deleted => 0, created_ts => $dt, modified_ts => $dt };
    return $self->db->insert( $table, $insert_params );
}

# $self->safe_update($table, \%search_params, \%update_params);
sub safe_update {
    my ( $self, $table, $search_params, $update_params ) = @_;
    my $dt       = $self->time_stamp;
    my $q_params = +{ %{$search_params}, deleted     => 0, };
    my $u_params = +{ %{$update_params}, modified_ts => $dt, };
    return $self->db->single_to( $table, $q_params )->update($u_params);
}

sub insert_csv {
    my $file = File::Spec->catfile( home(), '..', 'backup', 'KEN_ALL.CSV' );
    if ( $ENV{"ZSEARCH_MODE"} && ( $ENV{"ZSEARCH_MODE"} eq 'test' ) ) {
        $file = File::Spec->catfile( home(), '..', 'backup', '40FUKUOK.CSV' );
    }
    return $file;
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

# file
sub home          { $FindBin::RealBin; }
sub db_file_path  { File::Spec->catfile( home(), '..', 'db', db_file() ); }
sub db_dir_path   { File::Spec->catfile( home(), '..', 'db' ); }
sub sql_file_path { File::Spec->catfile( home(), '..', 'zsearch.sql' ); }

sub db_file {
    my $db_file = 'zsearch.db';
    if ( $ENV{"ZSEARCH_MODE"} && ( $ENV{"ZSEARCH_MODE"} eq 'test' ) ) {
        $db_file = 'zsearch-test.db';
    }
    return $db_file;
}

sub dump_file_path {
    File::Spec->catfile( home(), '..', 'backup', dump_file() );
}

sub dump_file {
    my $dump_file = 'zsearch.dump';
    if ( $ENV{"ZSEARCH_MODE"} && ( $ENV{"ZSEARCH_MODE"} eq 'test' ) ) {
        $dump_file = 'zsearch-test.dump';
    }
    return $dump_file;
}

1;

__END__
