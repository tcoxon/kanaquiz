#!/usr/bin/perl

use strict;
use warnings;

use utf8;
binmode STDOUT, ":utf8";

my ($open_quote, $close_quote) = ('「','」');

my %hg_map = (
    "あ" => "a",
    "い" => "i",
    "う" => "u",
    "え" => "e",
    "お" => "o",
    "か" => "ka",
    "き" => "ki",
    "く" => "ku",
    "け" => "ke",
    "こ" => "ko",
    "さ" => "sa",
    "し" => "shi",
    "す" => "su",
    "せ" => "se",
    "そ" => "so",
    "た" => "ta",
    "ち" => "chi",
    "つ" => "tsu",
    "て" => "te",
    "と" => "to",
    "な" => "na",
    "に" => "ni",
    "ぬ" => "nu",
    "ね" => "ne",
    "の" => "no",
    "は" => "ha",
    "ひ" => "hi",
    "ふ" => "hu",
    "へ" => "he",
    "ほ" => "ho",
    "ま" => "ma",
    "み" => "mi",
    "む" => "mu",
    "め" => "me",
    "も" => "mo",
    "や" => "ya",
    "ゆ" => "yu",
    "よ" => "yo",
    "ら" => "ra",
    "り" => "ri",
    "る" => "ru",
    "れ" => "re",
    "ろ" => "ro",
    "わ" => "wa",
    "を" => "wo",
    "ん" => "n",
);
my @hg_chars = keys %hg_map;

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

    my ($try,$done) = ("",0);
    do {
        print "\nEnter the ろまじ (romaji) for $open_quote$char$close_quote:    ";
        $try = get_ans();
        if ($try eq "") {
            print "Skipping question. Answer was '$hg_map{$char}'.\n";
            $done = 1;
        } elsif ($try =~ /^$hg_map{$char}$/i) {
            print "Huzzah! Correct answer!\n";
            $done = 1;
        } else {
            print "Incorrect. Try again.\n";
        }
    } until $done;

    print "\nNext question...";
}

sub main {
    print "ひらがな (hiragana) quiz\nNote: doesn't yet test muddied sounds or small つ、や、よ、ゆ\n";

    while (1) {
        my $char = $hg_chars[int rand @hg_chars];
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
