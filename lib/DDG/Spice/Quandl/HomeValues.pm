package DDG::Spice::Quandl::HomeValues;
# ABSTRACT: Home values for US zipcodes through Quandl

use DDG::Spice;
use Text::Trim;
use YAML::XS qw( Load );

# meta data
# Initially this is will work with zip codes, but will expand
# to other region identifiers
#
primary_example_queries "27514 home values";
secondary_example_queries "one bedroom houses 27514";
description "Home values for a given region";
name "Home Values";
code_url "https://github.com/brianrisk/zeroclickinfo-spice";
icon_url "https://www.quandl.com/favicon.ico";
topics "economy_and_finance";
category "finance";
attribution web => ["https://www.quandl.com", "Quandl"],
            twitter => "quandl";

# hash associating triggers with indicator codes
my $trigger_hash = Load(scalar share('home_values_triggers.yml')->slurp);

# triggers sorted by length so more specific is used first
my @trigger_keys = sort { length $b <=> length $a } keys($trigger_hash);

# defining our triggers
triggers any => @trigger_keys;

# to set an environmental variable:
# duckpan env set <name> <value>

# set spice parameters
spice to => 'http://quandl.com/api/v1/datasets/ZILLOW/$1.json?auth_token={{ENV{DDG_SPICE_QUANDL_APIKEY}}}&rows=2';
spice wrap_jsonp_callback => 1;
spice proxy_cache_valid => "418 1d";

handle sub {

    # will hold region such as "27510", "Carrboro" etc
    # NOTE: only zip codes supported for time being
    my $region;

    # will hold the type of region such as "ZIP", "CITY" etc
    # NOTE: only zip codes supported for time being
    my $indicator_type;

    # checking for 5-digit zip codes
    $_ =~ m/\b(\d{5})\b/;
    if ($1) {
        $region = $1;
        $indicator_type = "ZIP";
    }

    # exit if no region defined
    return unless ($region);

    # only return if we found a region in the search query
    my $query = lc $_;
    # iterate through trigger phrases in their file-order
    for my $trigger (@trigger_keys) {
        # return if the trigger phrase is in the query
        if ( $query =~ /$trigger/ ) {
            return $indicator_type . "_" . $trigger_hash->{$trigger} . "_" . $region;
        }
    };

    return;
};

1;



