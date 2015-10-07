#!/usr/bin/env perl6

use v6;
use MIME::Base64;

# At http://neo4j.com/developer/language-guides/
#    POST one or more cypher statements with parameters per request to the server
#    Keep transactions open over multiple requests
#    Choose different result formats
#    Execute management operations or introspect the database

# Server connect
#
my Str $host = 'localhost';
my Int $port = 7474;
my IO::Socket::INET $sock .= new( :$host, :$port);
say "S: {$sock.perl}";

# Authenticate
#
my Str $auth = MIME::Base64.encode-str("neo4j:P0nnuk1");

my $r = request(header( 'GET', '/user/neo4j'));

$r = request(header( 'GET', '/db/data/'));

# Do something
#
my $cmd = q:to/EOQ/;
  { "statements":
    [ { "statement":    "CREATE (n) RETURN id(n)"},
      { "statement":    "CREATE (n {p}) RETURN n",
        "parameters": {
          "p": {
            "name":       "Node 1",
            "addr":       "localhost"
          }
        }
      }
    ]
  }
  EOQ

$r = request(header( 'POST', '/db/data/transaction/commit', $cmd));

#`{{
# Do something more
#
$cmd = q:to/EOQ/;
  { "statement":      "MATCH (p:Person) RETURN p"
  }
  EOQ

$r = request(qq:to/EO-HTTP-POST/);
  POST /db/data/transaction/commit HTTP/1.1
  Accept: application/json; charset=UTF-8
  Content-Type: application/json

  $cmd
  EO-HTTP-POST
}}


$sock.close;


#-------------------------------------------------------------------------------
#
multi sub header ( 'GET', Str:D $path --> Str ) {

  my Str $header = qq:to/EO-HTTP-GET/;
    GET $path HTTP/1.1
    Host: localhost:7474
    Accept: application/json; charset=UTF-8
    Content-Length: 0
    Authorization: Basic $auth
    EO-HTTP-GET
  
  return "$header\n";
}

multi sub header ( 'POST', Str:D $path, Str:D $body --> Str ) {

  my Int $body-size = $body.chars;
  my Str $header = qq:to/EO-HTTP-POST/;
    POST $path HTTP/1.1
    Host: localhost:7474
    Accept: application/json; charset=UTF-8
    Content-Length: $body-size
    Content-Type: application/json
    Authorization: Basic $auth

    $body
    EO-HTTP-POST

  return $header;
}

#-------------------------------------------------------------------------------
#
sub request ( Str:D $req --> Str ) {

  say "Request:\n$req";

  my $result = '';
  $sock.print($req);

#    while my $r = $sock.get {
#      $result ~= $r;
#    }

    $result = $sock.recv;

    say "Response:\n$result";
    say '';

  return $result;
}

