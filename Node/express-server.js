// *******************************************
// DATABASE SETUP ****************************
// *******************************************
var MongoClient = require('mongodb').MongoClient;
var url = 'mongodb://localhost:27017/test'
var quotes
var topquote

// *******************************************
// EXPRESS SETUP  ****************************
// *******************************************

var express = require('express');
var app = express();
var router = express.Router();    
var path = require('path');
var bodyParser = require('body-parser');

app.use('/demo', express.static(path.join(__dirname, '..', '..', '..','static')));
app.use(bodyParser.json());
app.set('json spaces', 2);

// *******************************************
// FRONT PAGE APPLICATION AND GREETING *******
// *******************************************

// index with helpful message
app.get('/', function(request, reply) {
  reply.send('Hello world from express');
});

// *******************************************
// REST API ROUTES ***************************
// *******************************************

app.use('/api', router); // all routes will be found at /api/quotes

// QUOTE LIST
router.route('/quotes')  // app processes request based on combo of endoint & method(s) -> dot.notation
  .get(function(request, reply)  {
      quotes.find().sort({index:-1}).limit(10).toArray((err, results) => {
	      reply.send(results)
      })
  })

// RANDOM QUOTE FROM THE DATABASE
router.route('/quotes/random')
  .get(function(request, reply) {
    var random = Math.floor(Math.random()*topquote)
    quotes.findOne({"index":random}, (err, results) => {
       reply.send(results)
    })
  })

// SINGLE QUOTE
router.route('/quotes/:index')
  .get(function(request, reply) {
    index = parseInt(request.params.index) // pulls index from the path / parseInt takes from string to int
    quotes.findOne({"index":index}, (err, results) => {
       reply.send(results)
    })
  })

// ********************************************
// SERVERS ************************************
// ********************************************

MongoClient.connect(url, function(err, database)  {
    if (err) return console.log(err)
    console.log("Connected successfully to database server");
    quotes = database.collection('quotes')

    // Find the largest index for creating new quotes
    quotes.find().sort({"index": -1}).limit(1).toArray((err, quote) => {
      topquote = quote[0]["index"]
    })

    app.listen(8080, "0.0.0.0", function() {
      console.log('Express is listening to http://0.0.0.0:8080');
    })
})


