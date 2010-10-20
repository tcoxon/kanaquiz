#!/usr/bin/perl

use strict;
use warnings;
use Encode qw/encode decode/;
use Lingua::JA::Romaji qw/kanatoromaji romajitokana/;
use Getopt::Long;

use utf8;
binmode STDOUT, ":utf8";

my ($open_quote, $close_quote) = ('「','」');
my $romaji_text;

sub eucjp2utf8 {
    decode("euc-jp", shift)
}
sub utf82eucjp {
    encode("euc-jp", shift)
}

my $kana;
my @hiragana = map {eucjp2utf8($_)} keys %Lingua::JA::Romaji::hiragana;
my @katakana = map {eucjp2utf8($_)} keys %Lingua::JA::Romaji::katakana;

sub kana2roma {
    lc eucjp2utf8(kanatoromaji(utf82eucjp(shift)))
}

sub roma2kana {
    eucjp2utf8(romajitokana(eucjp2utf8(shift), $kana))
}

sub get_ans {
    my $line = <STDIN>;
    if (defined $line) {
        chomp $line;
        $line;
    } else {
        die "eof";
    }
}

sub do_test {
    my $char = shift;
    my $roma = kana2roma($char);

    my ($try,$done) = ("",0);
    do {
        print "\nEnter the $romaji_text (romaji) for $open_quote$char$close_quote:    ";
        $try = get_ans();
        if ($try eq "") {
            print "Skipping question. Answer was '$roma'.\n";
            $done = 1;
        } elsif (roma2kana($try) eq $char) {
            print "Huzzah! Correct answer!\n";
            $done = 1;
        } else {
            print "Incorrect. Try again.\n";
        }
    } until $done;

    print "\nNext question...";
}

sub select_char {
    my $charlist = shift;
    my ($char,$roma);
    while (!defined $char || $char eq "" || $roma =~ /x/ ||
        $char eq $roma)
    {
        $char = $charlist->[int rand scalar @$charlist];
        $roma = kana2roma($char);
    }
    $char
}

sub main {
    my $opt_ok = GetOptions("kana=s" => \$kana);
    if (!$opt_ok || ($kana !~ /hira/i && $kana !~ /kata/i)) {
        print "Pass either --kana=hira or --kana=kata.\n";
        return 1;
    }
    my $do_hira = ($kana =~ /hira/i);
    my $charlist;

    if ($do_hira) {
        print "ひらがな (hiragana) quiz\n";
        $romaji_text = "ろまじ";
        $charlist = \@hiragana;
    } else {
        print "カタカナ (katakana) quiz\n";
        $romaji_text = "ロマジ";
        $charlist = \@katakana;
    }

    while (1) {
        my $char = select_char($charlist);
        eval {
            do_test($char);
        };
        if ($@ =~ /^eof/) {
            print "\n";
            last;
        } elsif ($@) {
            die;
        }
    }

    return 0;
}


exit main();
