package Devel::REPL::Plugin::Completion;
use Devel::REPL::Plugin;
use Scalar::Util 'weaken';
use PPI;
use namespace::clean -except => [ 'meta' ];

has current_matches => (
  is => 'rw',
  isa => 'ArrayRef',
  lazy => 1,
  default => sub { [] },
);

has match_index => (
  is => 'rw',
  isa => 'Int',
  lazy => 1,
  default => sub { 0 },
);

sub BEFORE_PLUGIN {
  my ($self) = @_;

  my $weakself = $self;
  weaken($weakself);

  $self->term->Attribs->{attempted_completion_function} = sub {
    $weakself->_completion(@_);
  };
}

sub _completion {
  my ($self, $text, $line, $start, $end) = @_;

  # we're discarding everything after the cursor for completion purposes
  # we can't just use $text because we want all the code before the cursor to
  # matter, not just the current word
  substr($line, $end) = '';

  my $document = PPI::Document->new(\$line);
  return unless defined($document);

  $document->prune('PPI::Token::Whitespace');

  my @matches = $self->complete($text, $document);

  # iterate through the completions
  return $self->term->completion_matches($text, sub {
    my ($text, $state) = @_;

    if (!$state) {
      $self->current_matches(\@matches);
      $self->match_index(0);
    }
    else {
      $self->match_index($self->match_index + 1);
    }

    return $self->current_matches->[$self->match_index];
  });
}

sub complete {
  return ();
}

1;

