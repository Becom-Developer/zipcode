package Zsearch::DB;
use strict;
use warnings;
use utf8;
use SQLite::Simple;
use Pickup;
sub new    { bless {}, shift; }
sub helper { Pickup->new->helper; }

# file
sub home           { helper->home; }
sub homedb         { helper->homedb; }
sub homebackup     { helper->homebackup; }
sub sql_file_path  { helper->sql_file_path; }
sub dump_file_path { helper->dump_file_path; }
sub db_file_path   { helper->db_file_path; }

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

1;

__END__
