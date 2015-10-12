#`{{
  Testing;
    Database
}}

#BEGIN { @*INC.unshift( './t' ) }
#use Test-support;

use v6;
use Test;

use Neo4j::Database;
use Neo4j::Connection;
use Neo4j::User;

#-------------------------------------------------------------------------------
#
subtest {
  my Neo4j::Connection $connection .= new( :host<localhost>, :port(7474));
  my Neo4j::Database $database = $connection.database('data');
  is $database.^name, 'Database', 'Database set';
  is $database.path, '/db/data/', 'Check path';

}, "Database tests";

#-------------------------------------------------------------------------------
# Cleanup
#

done-testing();
exit(0);
