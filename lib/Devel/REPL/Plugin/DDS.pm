package Devel::REPL::Plugin::DDS;

use Moose::Role;
use Data::Dump::Streamer ();

around 'print' => sub {
  my $orig = shift;
  my $self = shift;
  my $to_dump = (@_ > 1) ? [@_] : $_[0];
  my $out;
  if (ref $to_dump) {
    my $dds = Data::Dump::Streamer->new;
    $dds->Freezer(sub { "$_[0]"; });
    $dds->Data($to_dump);
    $out = $dds->Out;
  } else {
    $out = $to_dump;
  }
  $self->$orig($out);
};

1;
