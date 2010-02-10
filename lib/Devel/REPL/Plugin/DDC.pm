package Devel::REPL::Plugin::DDC;

use Devel::REPL::Plugin;
use Data::Dumper::Concise ();

around 'format_result' => sub {
  my $orig = shift;
  my $self = shift;
  my $to_dump = (@_ > 1) ? [@_] : $_[0];
  my $out;
  if (ref $to_dump) {
    if (overload::Method($to_dump, '""')) {
      $out = "$to_dump";
    } else {
      $out = Data::Dumper::Concise::Dumper($to_dump);
    }
  } else {
    $out = $to_dump;
  }
  $self->$orig($out);
};

1;

__END__

=head1 NAME

Devel::REPL::Plugin::DDC - Format results with Data::Dumper::Concise

=head1 SYNOPSIS

 # in your re.pl file:
 use Devel::REPL;
 my $repl = Devel::REPL->new;
 $repl->load_plugin('DDS');
 $repl->run;

 # after you run re.pl:
 $ map $_*2, ( 1,2,3 )
[
  2,
  4,
  6
];

 $

=cut

