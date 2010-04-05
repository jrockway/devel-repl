use strict;
use warnings;
use Test::More;

my $in;
my $out;

{ package Mock::Frontend;
  use Moose;
  with 'Devel::REPL::Frontend::API';

  sub read { return $in };
  sub print { shift; $out .= join '', @_ };
}

{ package Mock::Backend;
  use Moose;
  with 'Devel::REPL::Backend::Default', 'MooseX::Object::Pluggable';
}

my $front = Mock::Frontend->new;
my $back  = Mock::Backend->new;
$back->load_plugin('+Devel::REPL::Plugin::LexEnv');

{ package Mock::Loop;
  use Moose;
  with 'Devel::REPL::Loop::Default';
  sub frontend { $front }
  sub backend  { $back }
}

my $repl = Mock::Loop->new;

{
    $out = '';
    $in = 'my $foo = 42';
    $repl->run_once;
    is $out, '42', 'got output';
}

{
    $out = '';
    $in = '$foo + 1';
    $repl->run_once;
    is $out, '43', 'got output dependent on lexenv';
}

{
    $out = '';
    $in = '$bar + 1';
    $repl->run_once;
    like $out, qr/^Compile error/, q{can't use $bar};
}

done_testing;
