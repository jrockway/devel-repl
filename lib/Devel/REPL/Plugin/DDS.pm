package Devel::REPL::Plugin::DDS;

use Devel::REPL::Plugin;
use Data::Dump::Streamer ();

around 'format_result' => sub {
  my $orig = shift;
  my $self = shift;
  my $to_dump = (@_ > 1) ? [@_] : $_[0];
  my $out;
  if (ref $to_dump) {
    if (overload::Method($to_dump, '""')) {
      $out = "$to_dump";
    } else {
      my $dds = Data::Dump::Streamer->new;
      $dds->Freezer(sub { "$_[0]"; });
      $dds->Data($to_dump);
      $out = $dds->Out;
    }
  } else {
    $out = $to_dump;
  }
  $self->$orig($out);
};

1;

__END__

=head1 NAME

Devel::REPL::Plugin::DDS - Format results with Data::Dump::Streamer

=cut

