#!/usr/bin/perl

package Devel::REPL::Plugin::Peek;
use Devel::REPL::Plugin;

use Devel::Peek qw(Dump);

use namespace::clean -except => [ 'meta' ];

sub BEFORE_PLUGIN {
    my $self = shift;
    $self->load_plugin('Turtles');
}

sub expr_command_peek {
  my ( $self, $eval, $code ) = @_;

  my @res = $self->eval($code);

  if ( $self->is_error(@res) ) {
    return $self->format(@res);
  } else {
    # can't override output properly
    # FIXME do some dup wizardry
    Dump(@res);
    return ""; # this is a hack to print nothing after Dump has already printed. PLZ TO FIX KTHX!
  }
}

__PACKAGE__

__END__

=pod

=head1 NAME

Devel::REPL::Plugin::Peek - L<Devel::Peek> plugin for L<Devel::REPL>.

=head1 SYNOPSIS

  repl> #peek "foo"
  SV = PV(0xb3dba0) at 0xb4abc0
    REFCNT = 1
    FLAGS = (POK,READONLY,pPOK)
    PV = 0x12bcf70 "foo"\0
    CUR = 3
    LEN = 4

=head1 DESCRIPTION

This L<Devel::REPL::Plugin> adds a C<peek> command that calls
L<Devel::Peek/Dump> instead of the normal printing.

=head1 SEE ALSO

L<Devel::REPL>, L<Devel::Peek>

=head1 AUTHOR

Yuval Kogman E<lt>nothingmuch@woobling.orgE<gt>

=cut
