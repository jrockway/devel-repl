package Devel::REPL::Plugin::CompletionDriver::Keywords;
use Devel::REPL::Plugin;
use B::Keywords qw/@Functions @Barewords/;
use namespace::clean -except => [ 'meta' ];

around complete => sub {
  my $orig = shift;
  my ($self, $text, $document) = @_;

  # recursively find the last element
  my $last = $document;
  while ($last->can('last_element') && defined($last->last_element)) {
      $last = $last->last_element;
  }

  return $orig->(@_)
    unless $last->isa('PPI::Token::Word');

  my $re = qr/^\Q$last/;

  return $orig->(@_),
         grep { $_ =~ $re } @Functions, @Barewords;
};

1;

