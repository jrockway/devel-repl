use strict;
use warnings;
use Test::More;
use Test::Exception;

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
  with 'Devel::REPL::Backend::Default';
}

my $front = Mock::Frontend->new;
my $back  = Mock::Backend->new;

{ package Mock::Loop;
  use Moose;
  with 'Devel::REPL::Loop::Default';
  sub frontend { $front }
  sub backend  { $back }
}

my $repl = Mock::Loop->new;

{
    $in = '2 + 2';
    lives_ok {
        $repl->run_once;
    } 'run_once lives in this case';

    is $out, '4', '2 + 2 is 4!';
}

{
    $out = '';
    $in = 'this is not valid perl!';

    lives_ok {
        $repl->run_once_safely;
    } "errors don't cause the REPL to die";
    like $out, qr/^Compile error: syntax error/, 'but we get Compile error: ...';
}


done_testing;
