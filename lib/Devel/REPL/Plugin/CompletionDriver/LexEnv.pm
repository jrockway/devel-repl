package Devel::REPL::Plugin::CompletionDriver::LexEnv;
use Devel::REPL::Plugin;
use namespace::clean -except => [ 'meta' ];

sub AFTER_PLUGIN {
  my ($_REPL) = @_;

  if (!$_REPL->can('lexical_environment')) {
    warn "Devel::REPL::Plugin::CompletionDriver::LexEnv requires Devel::REPL::Plugin::LexEnv.";
  }
}

around complete => sub {
  my $orig = shift;
  my ($self, $text, $document) = @_;

  # recursively find the last element
  my $last = $document;
  while ($last->can('last_element') && defined($last->last_element)) {
      $last = $last->last_element;
  }

  return $orig->(@_)
    unless $last->isa('PPI::Token::Symbol');

  my $sigil = substr($last, 0, 1, '');
  my $re = qr/^\Q$last/;

  return $orig->(@_),
         # ReadLine is weirdly inconsistent
         map  { $sigil eq '%' ? '%' . $_ : $_ }
         grep { /$re/ }
         map  { substr($_, 1) } # drop lexical's sigil
         keys %{$self->lexical_environment->get_context('_')};
};

1;

