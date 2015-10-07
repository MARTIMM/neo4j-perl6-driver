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
#say $r.perl;
  is $r[0]<Content-Length>, 131, 'Content length = 131';

  ok !$r[1]<password_change_required>, "No password change";
  is $r[1]<password_change>,
     'http://localhost:7474/user/neo4j/password',
     $r[1]<password_change>;
  is $r[1]<username>, 'neo4j', $r[1]<username>;

}, "result tests";

#-------------------------------------------------------------------------------
# Cleanup
#

done-testing();
exit(0);
