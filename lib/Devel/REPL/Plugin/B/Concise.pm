#!/usr/bin/perl

package Devel::REPL::Plugin::B::Concise;
use Devel::REPL::Plugin;

use B::Concise ();

B::Concise::compileOpts(qw(-nobanner));

use namespace::clean -except => [ 'meta' ];

sub BEFORE_PLUGIN {
    my $self = shift;
    $self->load_plugin('Turtles');
}

sub AFTER_PLUGIN {
  my $self = shift;

  my $prefix = $self->default_command_prefix; 

  $self->add_turtles_matcher(qr/^
    \#(concise) \s+
    ( (?:\-\w+\s+)* ) # options for concise
    (.*) # the code
    /x);
}

sub expr_command_concise {
  my ( $self, $eval, $opts, $code ) = @_;

  die unless $code;

  my %opts = map { $_ => 1 } (split /\s+/, $opts);

  my $sub = $self->compile($code, no_mangling => !delete($opts{"-mangle"}) );

  if ( $self->is_error($sub) ) {
    return $self->format($sub);
  } else {
    open my $fh, ">", \my $out;
    {
      local *STDOUT = $fh;
      B::Concise::compile(keys %opts, $sub)->();
    }

    return $out;
  }
}

__PACKAGE__

__END__

=pod

=head1 NAME

Devel::REPL::Plugin::B::Concise - B::Concise dumping of expression optrees

=head1 SYNOPSIS

  repl> #concise -exec -terse {
  > foo => foo(),
  > }
  COP (0x138b1e0) nextstate 
  OP (0x13bd280) pushmark 
  SVOP (0x138c6a0) const  PV (0xbbab50) "foo" 
  OP (0x13bbae0) pushmark 
  SVOP (0x13bcee0) gv  GV (0xbbb250) *Devel::REPL::Plugin::B::Concise::foo 
  UNOP (0x13890a0) entersub [1] 
  LISTOP (0x13ba020) anonhash 
  UNOP (0x5983d0) leavesub [1] 

=head1 DESCRIPTION

This plugin provides a C<concise> command that uses L<B::Concise> to dump
optrees of expressions.

The code is not actually executed, which means that when used with
L<Deve::REPL::Plugin::OutputCache> there is no new value in C<_>.

The command takes the same options as L<B::Concise/compile>, e.g. C<-basic> or
C<-exec> to determine the dump order, C<-debug>, C<-concise> and C<-terse> to
determine the formatting, etc.

=head1 AUTHOR

Yuval Kogman E<lt>nothingmuch@woobling.orgE<gt>

=cut


