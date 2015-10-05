#`{{
  Testing;
    Connection
}}

#BEGIN { @*INC.unshift( './t' ) }
#use Test-support;

use v6;
use Test;
use MIME::Base64;

#use Neo4j;
use Neo4j::Connection;
use Neo4j::User;

#-------------------------------------------------------------------------------
#
subtest {
  my Neo4j::Connection $connection .= new( :host<localhost>, :port(14702));
  is $connection.^name, 'Connection', 'Have a connection object';
  is $connection.status, Neo4j::CONNECT-FAIL, "Connection failed";

  $connection .= new( :host<localhost>, :port(7474));
  is $connection.^name, 'Connection', 'Have a connection object';
  is $connection.status, Neo4j::SUCCESS, "Connection successful";

}, "Connection tests";

#-------------------------------------------------------------------------------
#
subtest {
  my Neo4j::User $user .= new( :user<m>, :password<p>);
  is( $user.uname, 'm', "User 'm'");
  is( $user.b64-auth,
      MIME::Base64.encode-str("m:p"),
      "Encoded as {$user.b64-auth}"
    );

}, "User tests";

#-------------------------------------------------------------------------------
# Cleanup
#

done-testing();
exit(0);
