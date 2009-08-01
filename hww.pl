#!/usr/bin/env perl
package hww_main;    # For safety. package 'main' is in hw.pl

use strict;
use warnings;
use utf8;

use FindBin;
our $BASE_DIR;
our $HWW_LIB;
BEGIN {
    $BASE_DIR = $FindBin::Bin;
    $HWW_LIB  = "$FindBin::Bin/lib-hww";
}
use lib $HWW_LIB;

use HWW;
use HWW::UtilSub;



### sub ###
sub usage () {
    HWW->dispatch('help');
}

sub version () {
    HWW->version(@_);
}

# for hw.pl
sub restore_hw_opt {
    my %opt = @_;
    my @argv;

    while (my ($k, $v) = each %opt) {
        # deref.
        $v = $$v;
        # option was not given.
        next    unless defined $v;

        if ($k =~ s/(.*)=s$/$1/) {
            debug("restore: option -$k => $v");
            push @argv, "-$k", $v;
        } else {
            debug("restore: option -$k");
            push @argv, "-$k";
        }
    }

    return @argv;
}



### main ###
unless (@ARGV) {
    usage();
    exit -1;
}
my ($hww_args, $subcmd, $subcmd_args) = split_opt(@ARGV);

my $show_help;
my $show_version;
our $no_cookie;
# hw.pl's options.
our %hw_opt = (
    t => \my $t,

    'u=s' => \my $u,

    'p=s' => \my $p,

    'a=s' => \my $a,

    'T=s' => \my $T,

    'g=s' => \my $g,

    'f=s' => \my $f,

    M => \my $M,

    'n=s' => \my $n,

    S => \my $S,
);


# do not change $hww_args.
our $debug;
our $debug_stderr;
my %hww_opt = (
    help => \$show_help,
    version => \$show_version,

    d => \$debug,
    debug => \$debug,

    D => \$debug_stderr,
    'debug-stderr' => \$debug_stderr,

    C => \$no_cookie,
    'no-cookie' => \$no_cookie,

    %hw_opt,

    # TODO long version of hw.pl's options
    # trivial => \$trivial,
    # 'username=s' => \$username,
    # 'password=s' => \$password,
    # 'agent=s' => \$agent,
    # 'timeout=s' => \$timeout,
    # 'group=s' => \$group,
    # 'file=s' => \$entry_file,
    # 'config-file=s'
    # ssl => \$ssl,
);

get_opt($hww_args, \%hww_opt) or do {
    warning "arguments error";
    sleep 1;
    usage();
};

{
    # restore $hww_args for hw.pl
    local @ARGV = restore_hw_opt(%hw_opt);
    debug(sprintf 'restored @ARGV (for hw.pl): [%s]', join(' ', @ARGV));

    # load hw.pl and let it process @ARGV.
    # (pass only hw.pl's options)
    #
    # to use subroutine which manipulates API without module.
    require 'hw.pl';
}

# apply the result options which was parsed in this script to hw.pl
{
    no warnings 'once';

    $hw_main::cmd_opt{c} = 1 unless $no_cookie;    # use cookie. (default)
    $hw_main::cmd_opt{d} = 1 if $debug;
    # update %hw_main::cmd_opt with %hw_opt.
    %hw_main::cmd_opt = (%hw_main::cmd_opt, map {
        defined $hw_opt{$_} ?    # if option was given
        ((split '=')[0] => $hw_opt{$_}) :
        ()
    } keys %hw_opt);
}


usage()   if $show_help;
version() if $show_version;
usage()   unless defined $subcmd;

HWW->dispatch($subcmd => $subcmd_args);


__END__

=head1 NAME

    hww.pl - Hatena Diary Writer Wrapper


=head1 SYNOPSIS

    $ perl hww.pl [OPTIONS] COMMAND [ARGS]


=head1 OPTIONS

    these options for 'hww.pl'.
    if you see the help of command options, do it.
    $ perl hww.pl help <command>

=over

=item --help

show this help text.

=item --version

show version.

=item -d, --debug

debug mode.

=item -C, --no-cookie

don't use cookie.
(don't call hw.pl with '-c' option)

=back


=head1 AUTHOR

tyru <tyru.exe@gmail.com>
