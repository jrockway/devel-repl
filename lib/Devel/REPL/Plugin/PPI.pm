#!/usr/bin/perl

package Devel::REPL::Plugin::PPI;
use Devel::REPL::Plugin;

use PPI;
use PPI::Dumper;

use namespace::clean -except => [ 'meta' ];

sub BEFORE_PLUGIN {
    my $self = shift;
    $self->load_plugin('Turtles');
}

sub expr_command_ppi {
  my ( $self, $eval, $code ) = @_;

  my $document = PPI::Document->new(\$code);
  my $dumper   = PPI::Dumper->new($document);
  return $dumper->string;
}

__PACKAGE__

__END__

=pod

=head1 NAME

Devel::REPL::Plugin::PPI - PPI dumping of Perl code

=head1 SYNOPSIS

  repl> #ppi Devel::REPL
  PPI::Document
    PPI::Statement
      PPI::Token::Word    'Devel::REPL'
        
  repl> #ppi {
  > warn $];
  > }
  PPI::Document
    PPI::Statement::Compound
      PPI::Structure::Block       { ... }
        PPI::Token::Whitespace    '\n'
        PPI::Statement
          PPI::Token::Word        'warn'
          PPI::Token::Whitespace          ' '
          PPI::Token::Magic       '$]'
          PPI::Token::Structure   ';'
        PPI::Token::Whitespace    '\n'

=head1 DESCRIPTION

This plugin provides a C<ppi> command that uses L<PPI::Dumper> to dump
L<PPI>-parsed Perl documents.

The code is not actually executed, which means that when used with
L<Deve::REPL::Plugin::OutputCache> there is no new value in C<_>.

=head1 AUTHOR

Shawn M Moore E<lt>sartak@gmail.comE<gt>

=cut


