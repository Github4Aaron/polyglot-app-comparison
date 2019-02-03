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
        return \@results;
};

post '/api/quotes' => sub {
        # Find the quote with the highest index and then add 1.
    my $query = $quotes->find()->sort({'index' => -1})->limit(1);
    my $topquote = $query->next;
    my $max_id = $topquote->{'index'} + 1;
    
    # get the author and content from the parameters
    if (!params->{content}) { #check for content
        status 400;
        return {message => "Content is required for new quotes."};
    }

    my %response = ( # sends a reference to a hash in the database for processing
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


get '/' => sub{
    return {message => "Hello from Perl and Dancer"};
};

set public => path(dirname(__FILE__));

get "/demo/?" => sub {
    send_file '/index.html'
};

dance;

