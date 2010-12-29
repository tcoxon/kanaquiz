#!/usr/bin/perl

use strict;
use warnings;
use Encode qw/encode decode/;
use Lingua::JA::Romaji qw/kanatoromaji romajitokana/;
use Getopt::Long;
use List::Util 'shuffle';

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

my $kana = 'hira';
my @hiragana = map {eucjp2utf8($_)} keys %Lingua::JA::Romaji::hiragana;
my @katakana = map {eucjp2utf8($_)} keys %Lingua::JA::Romaji::katakana;

my ($single_only,$test_all) = (0,0);

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

my ($qs_correct, $qs_wrong) = (0,0);

sub do_test {
    my $char = shift;
    my $roma = kana2roma($char);

    my ($try,$done) = ("",0);
    do {
        print "\nEnter the $romaji_text (romaji) for $open_quote$char$close_quote:    ";
        $try = get_ans();
        if ($try eq "") {
            print "Skipping question. Answer was '$roma'.\n";
            $qs_wrong ++;
            $done = 1;
        } elsif (roma2kana($try) eq $char) {
            print "Huzzah! Correct answer!\n";
            $qs_correct ++;
            $done = 1;
        } else {
            print "Incorrect. Try again.\n";
            $qs_wrong ++;
        }
    } until $done;

    print "\nNext question...";
}

my $q_no = 0;

sub testable_char {
    my $char = shift;
    my $roma = defined $char ? kana2roma($char) : undef;
    return defined $char && $char ne "" && $roma !~ /x/ &&
        $roma =~ /^[a-zA-Z]+$/ && (!$single_only || length $char == 1);
}

sub select_char {
    if ($test_all) {
        my $charlist = shift;
        if ($q_no < scalar @$charlist) {
            print " ", $q_no+1, "/", scalar @$charlist, " ";
            return $charlist->[$q_no++];
        } else {
            die ":end";
        }
    } else {
        my $charlist = shift;
        my $char;
        while (!testable_char($char)) {
            $char = $charlist->[int rand scalar @$charlist];
        }
        $char
    }
}

sub setup_test {
    my $charlist = shift;
    @$charlist = shuffle grep { testable_char($_) } @$charlist;
    print scalar @$charlist, " questions in test.\n";
}

sub main {
    my $opt_ok = GetOptions(
        "kana=s" => \$kana,
        "single_only|single_characters|single_chars" => \$single_only,
        "test_all|test-all" => \$test_all,
    );
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
    
    if ($test_all) {
        setup_test($charlist);
    }

    eval {
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
    };
    if ($@ =~ /^:end/) {
        print "\nEnd of test.\n";
    } elsif ($@) {
        die
    }

    print "\nSummary:\n";
    print "$qs_correct correct answers; $qs_wrong wrong answers.\n";
    if ($qs_correct + $qs_wrong != 0) {
        print "Score: ", int (($qs_correct+0.0)/($qs_correct+$qs_wrong)*100), "\%\n";
    } else {
        print "Score: 0%\n";
    }

    return 0;
}


exit main();
