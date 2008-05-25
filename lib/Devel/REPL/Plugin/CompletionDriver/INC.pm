package Devel::REPL::Plugin::CompletionDriver::INC;
use Devel::REPL::Plugin;
use File::Next;
use File::Spec;
use namespace::clean -except => [ 'meta' ];

around complete => sub {
  my $orig = shift;
  my ($self, $text, $document) = @_;

  my $last = $self->last_ppi_element($document, 'PPI::Statement::Include');

  return $orig->(@_)
    unless $last->isa('PPI::Statement::Include');

  my @elements = $last->children;
  shift @elements; # use or require

  # too late for us to care, they're completing on something like
  #     use List::Util qw(m
  # OR they just have "use " and are tab completing. we'll spare them the flood
  return $orig->(@_)
    if @elements != 1;

  my $package = shift @elements;
  my $outsep  = '::';
  my $insep   = '::';
  my $keep_extension = 0;

  # require "Module"
  if ($package->isa('PPI::Token::Quote'))
  {
      $outsep = $insep = '/';
      $keep_extension = 1;
  }
  elsif ($package =~ /'/)
  {
      # the goofball is using the ancient ' package sep, we'll humor him
      $outsep = q{'};
      $insep = "'|::";
  }

  my @directories = split $insep, $package;

  # split drops trailing fields
  push @directories, '' if $package =~ /(?:$insep)$/;
  my $final = pop @directories;
  my $final_re = qr/^\Q$final/;

  my @found;

  INC: for (@INC)
  {
    my $path = $_;
    for my $subdir (@directories)
    {
      $path = File::Spec->catdir($path, $subdir);
      -d $path or next INC;
    }

    opendir((my $dirhandle), $path);
    for my $match (grep { $_ =~ $final_re } readdir $dirhandle)
    {
      $match =~ s/\..*// unless $keep_extension;
      push @found, join $outsep, @directories, $match;
    }
  }

  return $orig->(@_), @found;
};

1;

