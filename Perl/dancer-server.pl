use Dancer;
use MongoDB;

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
        if (! scalar (@results)) {
            status 404;
            return;
        }
        return \@results;
};

post '/api/quotes' => sub {
    my $query = $quotes->find()->sort({'index' => -1})->limit(1);
    my $topquote = $query->next;
    my $max_id = $topquote->{'index'} + 1;
    
    # get the author and content from the parameters
    if (!params->{content}) {
        status 400;
        return {message => "Content is required for new quotes."};
    }

    my %response = (
        'author' => params->{author},
        'content' => params->{content},
        'index' => $max_id
    );

    my $response = $quotes->insert_one(\%response);
    status 201;
    return {"index"=>$max_id};
};

get '/api/quotes/random' => sub {
    my $max_item = $quotes->find()->sort({'index' => -1})->limit(1);
    my $quote = $max_item->next;
    my $max_id = $quote->{'index'};
    my $random = int(rand($max_id));
    my $response = $quotes->find_one({"index" => $random});
    return $response;
};


get '/api/quotes/:index' => sub {
    my $response = $quotes->find_one({"index" => int(params->{'index'})}); 
    if (!$response) {
        status 404;
        return;
    }
    return $response;
};

put '/api/quotes/:index' => sub {
    my $index = int(params->{index});
    if (!params->{content} && !params->{author}) {
        status 400;
        return {message => "Author or content are required for update"}
    };
    my $original = $quotes->find_one({index => $index});
    my $content = params->{content} ? params->{content} : $original->{content};
    my $author = params->{author} ? params->{author} : $original->{author};

    my $response = $quotes->update_one({index => $index},
    {
        '$set' =>
            {'author' => $author, 'content' => $content}
    });
    status 202;
    return {"index"=>$index};
};

#del '/api/quotes/:index' => sub {
#    my $response = $quotes->find_one({"index" => int(params->{'index'})}); 
#    if (!$response) {
#        status 404;
#        return;
#    }
#    $quotes->delete_one({index => int(params->{'index'})});
#    status 204;
#    return;
#};


del '/api/quotes/:index' => sub {
    my $response = $quotes->delete_one({index => int(params->{'index'})});
    if ($response->deleted_count == 0) {
        status 404;
        return;
    }
    status 204;
    return;
};

get '/' => sub{
    return {message => "Hello from Perl and Dancer"};
};

set public => path(dirname(__FILE__));

get "/demo/?" => sub {
    send_file '/index.html'
};

dance;

