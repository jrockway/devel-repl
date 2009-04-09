package Devel::REPL::Plugin::CompletionDriver::Globals;
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
    unless $last->isa('PPI::Token::Symbol')
        || $last->isa('PPI::Token::Word');

  my $sigil = $last =~ s/^[\$\@\%\&\*]// ? $1 : undef;
  my $re = qr/^\Q$last/;

  my @package_fragments = split qr/::|'/, $last;

  # split drops the last fragment if it's empty
  push @package_fragments, '' if $last =~ /(?:'|::)$/;

  # the beginning of the variable, or an incomplete package name
  my $incomplete = pop @package_fragments;

  # recurse for the complete package fragments
  my $stash = \%::;
  for (@package_fragments) {
    $stash = $stash->{"$_\::"};
  }

  # collect any variables from this stash
  my @found = grep { /$re/ }
              map  { join '::', @package_fragments, $_ }
              keys %$stash;

  # check to see if it's an incomplete package name, and add its variables
  # so Devel<TAB> is completed correctly
  for my $key (keys %$stash) {
      next unless $key =~ /::$/;            # only look at deeper packages
      next unless $key =~ /^\Q$incomplete/; # only look at matching packages
      push @found,
        map { join '::', @package_fragments, $_ }
        map { "$key$_" } # $key already has trailing ::
        keys %{ $stash->{$key} };
  }

  return $orig->(@_), @found;
};

1;

__END__

=head1 NAME

Devel::REPL::Plugin::CompletionDriver::Globals - Complete global variables, packages, namespaced functions

=head1 AUTHOR

Shawn M Moore, C<< <sartak at gmail dot com> >>

=cut

