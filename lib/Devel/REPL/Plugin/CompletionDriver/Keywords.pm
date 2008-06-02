package Devel::REPL::Plugin::CompletionDriver::Keywords;
use Devel::REPL::Plugin;
use B::Keywords qw/@Functions @Barewords/;
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
    unless $last->isa('PPI::Token::Word');

  # don't complete keywords on foo->method
  return $orig->(@_)
    if $last->sprevious_sibling
    && $last->sprevious_sibling->isa('PPI::Token::Operator')
    && $last->sprevious_sibling->content eq '->';

  my $re = qr/^\Q$last/;

  return $orig->(@_),
         grep { $_ =~ $re } @Functions, @Barewords;
};

1;

__END__

=head1 NAME

Devel::REPL::Plugin::CompletionDriver::Keywords - Complete Perl keywords and operators

=head1 AUTHOR

Shawn M Moore, C<< <sartak at gmail dot com> >>

=cut

