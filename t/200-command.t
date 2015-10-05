#`{{
  Testing;
    Command
}}

use v6;
use Test;

#use Neo4j;
use Neo4j::Connection;
use Neo4j::User;
use Neo4j::Header;
use Neo4j::Command;

#-------------------------------------------------------------------------------
#
subtest {
  my Neo4j::Header $header .= new;
  my $txt = $header.build-header(
    :method<GET>,
    :path</user/neo4j>,
    :hdata(
      { Host => 'localhost:7474',
        Content-Length => 0
      }
    )
  );

  ok $txt ~~ m:s/ ^ 'GET' '/user/neo4j' /, 'First line GET';
  ok $txt ~~ m:s/ 'Content-Length:' '0' /, 'Content length';
  ok $txt ~~ m:s/ 'Host:' 'localhost:7474' /, 'Host';
}, "Header";

#-------------------------------------------------------------------------------
#
subtest {
  my Neo4j::Connection $connection .= new( :host<localhost>, :port(7474));
  my Neo4j::Command $command .= new;
  my Str $cmd = $command.build-command( :$connection, :path</user/neo4j>);

  ok $cmd ~~ m:s/ ^ 'GET' '/user/neo4j' /, 'First line GET';
  ok $cmd ~~ m:s/ 'Content-Length:' '0' /, 'Content length';
  ok $cmd ~~ m:s/ 'Host:' 'localhost:7474' /, 'Host';

}, "Command simple";

#-------------------------------------------------------------------------------
#
subtest {
  my Neo4j::Connection $connection .= new( :host<localhost>, :port(7474));
  my Neo4j::User $user .= new( :user<m>, :password<p>);
  my Neo4j::Command $command .= new;

  my Str $statements = q:to/EOSTMTS/;
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
    EOSTMTS

  my $body-size = $statements.chars;

  my Str $cmd = $command.build-command(
    :$connection,
    :path</user/neo4j>,
    :$user,
    :body($statements)
  );
#say $cmd;

  ok $cmd ~~ m:s/ ^ 'POST' '/user/neo4j' /, 'First line POST';
  ok $cmd ~~ m:s/ 'Content-Length:' <$body-size> /, "Content length $body-size";
  ok $cmd ~~ m:s/ 'Host:' 'localhost:7474' /, 'Host';
  ok $cmd ~~ m:s/ 'Authorization:' 'Basic' /, 'Authorization';

}, "Command complex";


#-------------------------------------------------------------------------------
# Cleanup
#

done-testing();
exit(0);

=finish
