use v6;
use MIME::Base64;
use Neo4j;

package Neo4j {

  class User {
  
    has Str $.uname;
    has Str $!passwd;
    has Str $.b64-auth;

    #---------------------------------------------------------------------------
    #
    submethod BUILD( Str:D :$user, Str:D :$password ) {
      $!uname = $user;
      $!passwd = $password;
      $!b64-auth = MIME::Base64.encode-str("$user:$password");
    }
  }
}
