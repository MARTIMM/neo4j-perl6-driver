#`{{
  Testing;
    Send
}}

#BEGIN { @*INC.unshift( './t' ) }
#use Test-support;

use v6;
use Test;
use MIME::Base64;

#use Neo4j;
use Neo4j::Connection;
use Neo4j::User;
use Neo4j::Header;
use Neo4j::Command;

#-------------------------------------------------------------------------------
#
subtest {
  my Neo4j::Connection $connection .= new( :host<localhost>, :port(7474));

  my Str $result = q:to/EOR/;
    HTTP/1.1 200 OK
    Date: Tue, 06 Oct 2015 15:04:20 GMT
    Content-Type: application/json; charset=UTF-8
    Access-Control-Allow-Origin: *
    Content-Length: 131
    Server: Jetty(9.2.4.v20141103)

    {
      "password_change_required" : false,
      "password_change" : "http://localhost:7474/user/neo4j/password",
      "username" : "neo4j"
    }
    EOR

  my Array $r = $connection.unravel-result($result);
  is $connection.cmd-status, Neo4j::SUCCESS, 'Success';
  is $connection.http-status, Neo4j::HTTP-SUCCESS, 'Http success';
  is $connection.http-reason, 'OK', 'OK';

  is $r[0]<Content-Length>, 131, 'Content length = 131';

  ok !$r[1]<password_change_required>, "No password change";
  is $r[1]<password_change>,
     'http://localhost:7474/user/neo4j/password',
     $r[1]<password_change>;
  is $r[1]<username>, 'neo4j', $r[1]<username>;

}, "result tests";

#-------------------------------------------------------------------------------
#
subtest {
  my Neo4j::Connection $connection .= new( :host<localhost>, :port(7474));
  my Str $cmd = $connection.build-command(:path</user/neo4j>);
#say '-' x 80, "\n", $cmd, "\n";

  my Array $r = $connection.send($cmd);
#say $r[0].perl, "\n\n", $r[1].perl, "\n", '-' x 80, "\n";

  is $connection.cmd-status, Neo4j::HTTP-ERROR, 'Failure';
  is $connection.http-status, Neo4j::HTTP-CLIENT-ERROR, 'Client failure';
  is $connection.http-reason, 'Unauthorized', 'Unauthorized';
  my $e = $r[1]<errors>[0];
  is $e<code>, "Neo.ClientError.Security.AuthorizationFailed", $e<code>;
  is $e<message>, "No authorization header supplied.", $e<message>;
  is $connection.neo-status, Neo4j::NEO-NOAUTHSUP, 'Neo4j::NEO-NOAUTHSUP';


  my Neo4j::User $user .= new( :user<m>, :password<p>);
  $cmd = $connection.build-command( :$user, :path</user/neo4j>);
  $r = $connection.send($cmd);

  is $connection.cmd-status, Neo4j::HTTP-ERROR, 'Failure';
  is $connection.http-status, Neo4j::HTTP-CLIENT-ERROR, 'Client failure';
  is $connection.http-reason, 'Unauthorized', 'Unauthorized';
  $e = $r[1]<errors>[0];
  is $e<code>, "Neo.ClientError.Security.AuthorizationFailed", $e<code>;
  is $e<message>, "Invalid username or password.", $e<message>;
  is $connection.neo-status, Neo4j::NEO-USRPWINV, 'Neo4j::NEO-USRPWINV';


  $user .= new( :user<neo4j>, :password<P0nnuk1>);
  $cmd = $connection.build-command( :$user, :path</user/neo4j>);
  $r = $connection.send($cmd);

  is $connection.cmd-status, Neo4j::SUCCESS, 'Success';
  is $connection.http-status, Neo4j::HTTP-SUCCESS, 'Authentication ok';
  is $connection.http-reason, 'OK', 'OK';
  $e = $r[1];
  ok !$e<password_change_required>, 'No password change required';
  is $e<password_change>, "http://localhost:7474/user/neo4j/password", $e<password_change>;
  is $e<username>, "neo4j", $e<username>;
  is $connection.neo-status, Neo4j::SUCCESS, 'Neo-status == cmd-status: Success';

}, "Command send receive";

#-------------------------------------------------------------------------------
#
subtest {

  my Neo4j::Connection $connection .= new( :host<localhost>, :port(7474));
  my Neo4j::User $user .= new( :user<neo4j>, :password<P0nnuk1>);
  my Hash $statements = {
    statements => [ ${
        statement => 'MATCH (n:Person) RETURN n'
      }
    ]
  };
  my $cmd = $connection.build-command( :$user, :path</db/data/transaction/commit>, :$statements);
  my Array $r = $connection.send($cmd);
  is $r[1]<errors>[0], Any, 'No errors'

}, "Command MATCH transaction commit";

#-------------------------------------------------------------------------------
#
subtest {

  my Neo4j::Connection $connection .= new( :host<localhost>, :port(7474));
  my Neo4j::User $user .= new( :user<neo4j>, :password<P0nnuk1>);
  my Hash $statements = {
    statements => [ ${
        statement => 'MATCH (n:Person) RETURN n'
      }
    ]
  };
  my $cmd = $connection.build-command( :$user, :path</db/data/transaction>, :$statements);
  my Array $r = $connection.send($cmd);
  
  

}, "Command MATCH start transaction and end with commit";

#-------------------------------------------------------------------------------
# Cleanup
#

done-testing();
exit(0);
