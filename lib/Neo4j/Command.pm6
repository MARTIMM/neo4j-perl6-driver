use v6;
use Neo4j;
use Neo4j::Header;
use Neo4j::User;
use JSON::Fast;

package Neo4j {

  class Command {
    
    has Neo4j::Header $.header;
    has Str $.json;

    #---------------------------------------------------------------------------
    #
    submethod BUILD (  ) {
      $!header .= new;
    }

    #---------------------------------------------------------------------------
    #
    method encode ( Hash:D $h ) {
      $!json = to-json($h);
    }

    #---------------------------------------------------------------------------
    #
    method decode ( Str:D $s = $!json --> Hash ) {
      return from-json($s);
    }

    #---------------------------------------------------------------------------
    #
    method build-command (
      :$connection where .^name eq 'Connection',
      Neo4j::User :$user,
      Str:D :$path,
      Str :$body is copy = ''
      --> Str
    ) {

      my Hash $h;

      $h<Host> = [~] $connection.host, ':', $connection.port;
      $h<Accept> = 'application/json; charset=UTF-8';
      $h<Content-Length> = $body.chars;
      $h<Content-Type> = 'application/json' if +$h<Content-Length>;

      if ?$user and my Str $auth = $user.b64-auth {
        $h<Authorization> = "Basic $auth";
      }

      my Str $method = +$h<Content-Length> ?? 'POST' !! 'GET';
      my Str $cmd = $!header.build-header( :$method, :$path, :hdata($h)) ~ "\n";
      $cmd ~ $body if +$h<Content-Length>;

      return $cmd;
    }
  }
}
