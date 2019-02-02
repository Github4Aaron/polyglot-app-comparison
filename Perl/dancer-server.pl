use Dancer;
use MongoDB;
# Perl syntax: $ - single value; @ - list of values; % - hash or named array


my $client = MongoDB->connect();
my $quotes = $client->get_database('test')->get_collection('quotes');

get '/api/quotes' => sub {
    my $response = $quotes->find()->sort({'index' => -1})->limit(10);
    my @results = ();
    while(my $quote = $response->next) {
                push (@results,
                        {"content" => $quote->{'content'},
                         "index"   => $quote->{'index'},
                         "author"  => $quote->{'author'}
                         }
                );
        } 
        return \@results;
};

get '/api/quotes/random' => sub {
    my $response = $quotes->find()->sort({'index' => -1})->limit(1);
    my $quote = $response->next;
    my $max_number = $quote->{'index'};
    my $random = int(rand($max_number));
    my $answer = $quotes->find_one({"index" => $random});
    return $answer;
};

get '/api/quotes/:index' => sub {
    my $response = $quotes->find_one({"index" => int(params->{'index'})}); 
    if (!$response) {
        status 404;
        return;
    }
    return $response;
};


get '/' => sub{
    return {message => "Hello from Perl and Dancer"};
};

set public => path(dirname(__FILE__));

get "/demo/?" => sub {
    send_file '/index.html'
};

dance;

