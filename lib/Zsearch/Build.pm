package Zsearch::Build;
use strict;
use warnings;
use utf8;
use Pickup;
use Zsearch::DB;
sub new    { bless {}, shift; }
sub error  { Pickup->new->error; }
sub render { Pickup->new->render; }
sub DB     { Zsearch::DB->new; }

sub db           { my ( $self, @args ) = @_; DB->db(@args); }
sub homedb       { DB->homedb; }
sub db_file_path { DB->db_file_path; }

sub start {
    my ( $self, @args ) = @_;
    my $opt = shift @args;
    return $self->error->commit("No arguments") if !$opt;

    # 初期設定時のdbファイル準備
    return $self->_init($opt)   if $opt->{method} eq 'init';
    return $self->_insert($opt) if $opt->{method} eq 'insert';
    return $self->_dump()       if $opt->{method} eq 'dump';
    return $self->_restore()    if $opt->{method} eq 'restore';
    return $self->error->commit(
        "Method not specified correctly: $opt->{method}");
}

sub _init {
    my ( $self, @args ) = @_;
    my $opt    = shift @args;
    my $params = $opt->{params};
    if ( exists $params->{name} ) {
        my $name = $params->{name};
        my $path = File::Spec->catfile( $self->homedb(), $name );
        if ( $ENV{"ZSEARCH_MODE"} && ( $ENV{"ZSEARCH_MODE"} eq 'test' ) ) {
            my $test_dir = $ENV{"ZSEARCH_TESTDIR"};
            $path = File::Spec->catfile( $test_dir, $name );
        }
        my $args = { db_file_path => $path, };
        return $self->db($args)->build();
    }
    return $self->db->build();
}

sub _dump    { shift->db->build_dump(); }
sub _restore { shift->db->build_restore(); }

sub _insert {
    my ( $self, @args ) = @_;
    my $opt = shift @args;
    return $self->db->build_insert( $opt->{params} );
}

1;

__END__
