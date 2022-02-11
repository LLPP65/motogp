#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use LWP::Simple;
use JSON qw( decode_json );
use Data::Dumper;
use Encode qw(encode_utf8);

#my $seasons_url = "https://www.motogp.com/api/results-front/be/results-api/seasons?test=1";
#my $events_url = "https://www.motogp.com/api/results-front/be/results-api/season/$season/events?finished=1";
#my $categories_url = "https://www.motogp.com/api/results-front/be/results-api/event/$event/categories";
#my $sessions_url = "https://www.motogp.com/api/results-front/be/results-api/event/$event/category/category/$category/sessions";
#my $results_url = "https://www.motogp.com/api/results-front/be/results-api/session/$sesion/classifications"

my %yearids;
my $key;
my $decoded_json;

########################################################################
# Seasons
########################################################################
my $seasons_url = "https://www.motogp.com/api/results-front/be/results-api/seasons";
$decoded_json = getJSON($seasons_url);
foreach my $result (@{$decoded_json}) {
    $yearids{$result->{year}} = $result->{id};
}
foreach $key (sort (keys(%yearids))) {
    printf("The ID for %s is %s \n",$key,$yearids{$key});
}

########################################################################
# Events
########################################################################

print "Enter the year you want ";
my $desired_year = <STDIN>; 
chomp $desired_year; 
exit 0 if ($desired_year eq ""); # If empty string, exit.

printf("OK, getting events for %s.\n",$desired_year);
my $events_url = sprintf("https://www.motogp.com/api/results-front/be/results-api/season/%s/events",$yearids{$desired_year});
printf("Event URL is %s \n",$events_url);

$decoded_json = getJSON($events_url);
#print Dumper $decoded_json;
my $event_counter=1;
my @event_array;

foreach my $result (@{$decoded_json}) {
    $event_array[$event_counter] = $result->{id};
    printf("%s %s %s\n",$event_counter,$result->{id},$result->{name});
    $event_counter++;
}

print "Enter the Event you want ";
my $desired_event = <STDIN>; 
chomp $desired_event; 
exit 0 if ($desired_event eq ""); # If empty string, exit.

########################################################################
# Categories
########################################################################

printf("OK, getting categories for %s (%s).\n",$desired_event,$event_array[$desired_event]);
my $categories_url = sprintf("https://www.motogp.com/api/results-front/be/results-api/event/%s/categories",$event_array[$desired_event]);
printf("Event URL is %s \n",$categories_url);

$decoded_json = getJSON($categories_url);
#print Dumper $decoded_json;
my $category_counter=1;
my @category_array;

foreach my $result (@{$decoded_json}) {
    $category_array[$category_counter] = $result->{id};
    printf("%s %s %s\n",$category_counter,$result->{id},$result->{name});
    $category_counter++;
}

print "Enter the Category you want ";
my $desired_category = <STDIN>; 
chomp $desired_category; 
exit 0 if ($desired_category eq ""); # If empty string, exit.

########################################################################
# Sessions
########################################################################

printf("OK, getting sessions for %s (%s).\n",$desired_category,$category_array[$desired_category]);
my $sessions_url = sprintf("https://www.motogp.com/api/results-front/be/results-api/event/%s/category/%s/sessions",$event_array[$desired_event],$category_array[$desired_category]);
printf("Session URL is %s \n",$sessions_url);

$decoded_json = getJSON($sessions_url);
#print Dumper $decoded_json;
my $session_counter=1;
my @session_array;

foreach my $result (@{$decoded_json}) {
    $session_array[$session_counter] = $result->{id};
    printf("%s %s %s %s\n",$session_counter,$result->{type},$result->{number},$result->{id});
    $session_counter++;
}

print "Enter the Session you want ";
my $desired_session = <STDIN>; 
chomp $desired_session; 
exit 0 if ($desired_session eq ""); # If empty string, exit.


########################################################################
# Classifications
########################################################################

printf("OK, getting classifications for %s (%s).\n",$desired_session,$session_array[$desired_session]);
my $classifications_url = sprintf("https://www.motogp.com/api/results-front/be/results-api/session/%s/classifications",$session_array[$desired_session]);
printf("Classifications URL is %s \n",$classifications_url);

$decoded_json = getJSON($classifications_url);
#print Dumper $decoded_json;
$decoded_json = $decoded_json->{classification};

foreach my $result (@{$decoded_json}) {
    printf("%s %s %s \n",$result->{position},$result->{rider}->{full_name},$result->{points});
}


########################################################################
exit;
########################################################################




########################################################################
sub getJSON($){
########################################################################
    my ($url) = @_;
    my $jsondata = get( $url );
    die "Could not get $url!" unless defined $jsondata;

    #$jsondata=encode_utf8($jsondata);
    #my $decoded_json = JSON->new->utf8->decode( $jsondata );

    return(JSON->new->utf8->decode( $jsondata ));

}
