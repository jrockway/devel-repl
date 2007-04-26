# First cut at handling packages.
#
# doesn't work very well, and totally doesn't work with the wrap_as_sub
# stuff ;) For comments only really

package Devel::REPL::Plugin::Packages;

use Moose::Role;

has 'current_package' => (
  isa      => 'Str',
  is       => 'rw',
  default  => 'main',
  lazy     => 1
);

around 'eval' => sub {
# we don't call forward to $orig here, since the new sub-wrapped system
# doesn't work. We spot package declarations and retain the name so
# that we can reenter the package for each statement. Not sure the
# regex is bob on, but then it doesn't work anyway...
  my $orig=shift;
  my ($self, $line)=@_;

  my @ret=("OOPS: ".__PACKAGE__.'$ret unset!');

#  $self->print("Line is: $line");
  if($line=~/\s*package\s([\w:]*)/) {
#    $self->print("Recognised as a package switch");
#    $ret=$self->$orig($line);
    @ret=eval $line;
#    $self->print("ret: @ret");
    # should check for good return here
    $self->current_package($1);
#    $self->print('curr pkg: '.$self->current_package);
  } else {
#    $self->print("Not a package switch");
    my $packaged_line='package ' . $self->current_package . '; '.$line;
#    $self->print("packaged line: $packaged_line");
#    @ret=$self->$orig($packaged_line);
    @ret=eval $packaged_line;
#    $self->print("ret: @ret");
  }
  return @ret;
};

1;

