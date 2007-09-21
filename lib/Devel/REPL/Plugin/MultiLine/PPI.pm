package Devel::REPL::Plugin::MultiLine::PPI;

use Moose::Role;
use PPI;
use namespace::clean -except => [ 'meta' ];

has 'continuation_prompt' => (
  is => 'rw', required => 1, lazy => 1,
  default => sub { '> ' }
);

around 'read' => sub {
  my $orig = shift;
  my ($self, @args) = @_;
  my $line = $self->$orig(@args);

  if (defined $line) {
    while (needs_continuation($line)) {
      my $orig_prompt = $self->prompt;
      $self->prompt($self->continuation_prompt);

      my $append = $self->read(@args);
      $line .= $append if defined($append);

      $self->prompt($orig_prompt);

      # ^D means "shut up and eval already"
      return $line if !defined($append);
    }
  }
  return $line;
};

sub needs_continuation
{
  my $line = shift;
  my $document = PPI::Document->new(\$line);
  return 0 if !defined($document);

  # this could use more logic, such as returning 1 on s/foo/ba<Enter>
  my $unfinished_structure = sub
  {
    my ($document, $element) = @_;
    return 0 unless $element->isa('PPI::Structure');
    return 1 unless $element->start && $element->finish;
    return 0;
  };

  return $document->find_any($unfinished_structure);
}

1;
