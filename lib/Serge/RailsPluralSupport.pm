package Serge::RailsPluralSupport;

use strict;

our @ISA = qw(Exporter);

use Serge::Util qw(po_is_msgid_plural glue_plural_string split_plural_string);
use YAML::XS qw(LoadFile);

our @EXPORT = qw(
    tree_is_plural
    rails_tree_to_value
    value_is_plural
    value_to_rails_tree
    mapping_configuration_file
);

our @EXPORT_OK = qw(
    plural_keys_for_language
);

my @PLURAL_KEYS = qw/zero one two few many other/;
my %PLURAL_KEYS = map{ $_, 1} @PLURAL_KEYS;

(my $_module_dir = __FILE__) =~ s{/[^/]+$}{};
my $mapping_configuration_file = File::Spec->rel2abs('../../config/plurals.yml', $_module_dir);

my $MAPPING;

sub mapping_configuration_file {
    my($new_file) = @_;
    die "$new_file does not exist!" unless (-f $new_file);

    $mapping_configuration_file = $new_file;
}

sub tree_is_plural {
    my ($tree) = @_;

    return 0 unless scalar(%$tree);

    my @keys = keys %$tree;

    # Special case: Rails does not consider a single .other key a plural
    return(0) if (join(',', @keys) eq 'other');

    foreach my $k (@keys) {
        return 0 unless exists($PLURAL_KEYS{$k}) && $PLURAL_KEYS{$k}
    }

    return 1;
}

sub rails_tree_to_value {
    my ($tree, $lang) = @_;

    # NOTE: this could be reduced to a hash slice, at the expense of
    # autovivifying all the (other) keys in the hash
    my @values = map { exists($$tree{$_}) && $$tree{$_} ? $$tree{$_} : () } @PLURAL_KEYS;

    glue_plural_string(@values);
}

sub value_is_plural {
    po_is_msgid_plural(@_);
}

sub value_to_rails_tree {
    my ($value, $lang, $path) = @_;

    my @values = split_plural_string($value);
    my @keys = plural_keys_for_language($lang);

    # Special case: Ruby i18n does not recognize a lone 'other' key as being pluralized
    if (join('/', @keys) eq 'other') {
        unshift @keys, 'one';
        $values[1] = $values[0] unless $values[1];
    }

    if (int(@values) != int(@keys)) {
        print "WARNING: $lang has plural keys [@keys], but $path has ", int(@values), " values.\n";
    }

    my $result = {};

    for( my $i = 0 ; $i <= $#values ; $i++) {
        my $plural = @keys[$i];
        last unless $plural;
        $result->{$plural} = $values[$i];
    }

    return $result;
}

sub plural_keys_for_language {
    my ($lang) = @_;

    $lang =~ s/(\w{2,3})([-_].*)?/\1/;

    unless ($MAPPING) {
        $MAPPING = LoadFile($mapping_configuration_file);
    }

    my $value = $MAPPING->{$lang};

    unless (ref($value) eq 'ARRAY') {
        print "WARNING: No plural values found for language: $lang. Returning default.\n";
        return qw/one other/;
    }

    @$value;
}

1;
