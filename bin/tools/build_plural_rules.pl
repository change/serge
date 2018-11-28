#!/usr/bin/env perl

use strict;
use XML::Twig;
use LWP::Simple;
use YAML::XS;
use File::Spec;

my $twig = new XML::Twig(twig_handlers => { pluralRules => \&plural_rules });
# Depending on environment variables, the HTTPS version may not return data
# my $xml = get('https://unicode.org/repos/cldr/trunk/common/supplemental/plurals.xml');
my $xml = get('http://unicode.org/repos/cldr/trunk/common/supplemental/plurals.xml');

my %plurals;
my %cache;

$twig->parse($xml);
#$twig->parsefile('/tmp/plurals.xml');

sub plural_rules {
    my($twig, $plural_rules)= @_;

    my @locales = split /\s+/, $plural_rules->att('locales');
    my @types = map { $_->att('count')} $plural_rules->children;
    my $key = join ',', @types;

    foreach my $locale (@locales) {
        my $list = $cache{$key} || \@types;
        $plurals{$locale} = $list;
        $cache{$key} = $list;
    }
}

(my $dir = $0) =~ s{/[^/]+$}{};

my $file = File::Spec->rel2abs('../../config/plurals.yml', $dir);
open OUT, '>', $file;
print OUT Dump \%plurals;
