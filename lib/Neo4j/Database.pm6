use v6;
use Neo4j;

package Neo4j {

  class Database {
  
    has Str $.name;
    has $!connection;
    has Neo4j::ErrorCode $.status;
    
    submethod BUILD ( :$connection where .^name eq 'Connection', Str :$name ) {
      $!connection = $connection;
      $!name = $name;
    }
    
    method path ( --> Str ) {
      return '/db/' ~ $!name ~ '/';
    }
  }
}
