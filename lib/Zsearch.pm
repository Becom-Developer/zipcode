package Zsearch;
use strict;
use warnings;
use utf8;
use FindBin;
use File::Spec;
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

sub dump {
    my ( $self, @args ) = @_;
    my $d = Data::Dumper->new( [ shift @args ] );
    return $d->Dump;
}

sub is_test_mode {
    return if !$ENV{"ZSEARCH_MODE"};
    return if $ENV{"ZSEARCH_MODE"} ne 'test';
    return 1;
}

sub zipcode_version {
    my ( $self, @args ) = @_;
    my $row = $self->valid_single( 'post', { id => 1 } );
    return '' if !$row;
    return $row->{version};
}

sub valid_single {
    my ( $self, $table, $params ) = @_;
    my $q_params = +{ %{$params}, deleted => 0, };
    return $self->db->single( $table, $q_params );
}

sub valid_search {
    my ( $self, $table, $params, $opt ) = @_;
    my $q_params = +{ %{$params}, deleted => 0, };
    return $self->db->search( $table, $q_params, $opt );
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
