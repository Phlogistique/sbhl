use POSIX qw(strftime);
use strict;

my %hl = {};

sub sig_print_text {
    my ($dest, $text, $stripped) = @_;
    my $level = $dest->{level};
    my $window = $dest->{window};
    my $num = $window->{refnum};
    my $time = strftime "%d %H:%M:%S", localtime;


    if ($level & MSGLEVEL_HILIGHT) {
        push @{$hl{$num}||=[]}, $time;
    }
}

my %hlidx = {};
sub scrollback_to_hl {
    my ($data, $server, $witem) = @_;
    if (! $witem) {
        Irssi::print("SBHL: not in a window!");
        return;
    }
    my $window = $witem->window();
    my $num = $window->{refnum};

    my $i = $hlidx{$num};

    my $next = ($data =~ /^\s*(n(ext)?)?\s*$/);
    my $prev = ($data =~ /^\s*p(rev)?\s*$/);

    if ($next) { $i++; }
    elsif ($prev) { $i--; }
    else { $i = $data; }

    my $time = @{$hl{$num}}[$i-1]; # because 0 is false, we start indexing at 1

    if ($time) {
        $hlidx{$num} = $i;
        $window->command("scrollback goto $time");
        $window->command("scrollback goto -" . int($window->{height} / 2)); # center screen
    } elsif ($next) {
        $window->command("scrollback end");
    } else {
        Irssi::print("Warning: no hilight numbered $i in window #$num");
    }
}
    
Irssi::signal_add("print text", "sig_print_text");
Irssi::command_bind("sbhl", "scrollback_to_hl");

