package Devel::REPL::Plugin::CompletionDriver::LexEnv;
use Devel::REPL::Plugin;
use namespace::clean -except => [ 'meta' ];

sub BEFORE_PLUGIN {
    my $self = shift;
    $self->load_plugin('Completion');
}

around complete => sub {
  my $orig = shift;
  my ($self, $text, $document) = @_;

  my $last = $self->last_ppi_element($document);

  return $orig->(@_)
    unless $last->isa('PPI::Token::Symbol');

  my $sigil = substr($last, 0, 1, '');
  my $re = qr/^\Q$last/;

  return $orig->(@_),
         # ReadLine is weirdly inconsistent
         map  { $sigil eq '%' ? '%' . $_ : $_ }
         grep { /$re/ }
         map  { substr($_, 1) } # drop lexical's sigil
         '$_REPL', keys %{$self->lexical_environment->get_context('_')};
};

1;

__END__

=head1 NAME

Devel::REPL::Plugin::CompletionDriver::LexEnv - Complete variable names in the REPL's lexical environment

=head1 AUTHOR

Shawn M Moore, C<< <sartak at gmail dot com> >>

=cut

