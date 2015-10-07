use v6;
use Neo4j;
use Neo4j::Database;
use Neo4j::Command;

package Neo4j {
  class Connection {

    has Str $.host;
    has Int $.port;
    has IO::Socket::INET $.sock;

    has Neo4j::ErrorCode $.status;

    # Two forms of handling methods from the same object
    #
    has Neo4j::Command $.c1 handles <
      build-command unravel-result
      http-status http-reason
    >;

    has Neo4j::Command $.c2 handles (
      :cmd-status<status>
    );

    #---------------------------------------------------------------------------
    #
    submethod BUILD ( Str:D :$host, Int:D :$port ) {
      $!host = $host;
      $!port = $port;
      self.connect;
      $!c1 = $!c2 .= new(:connection(self));
    }

    #---------------------------------------------------------------------------
    #
    multi method set ( 'host', Str:D $h ) {
      $!host = $h;
    }

    #---------------------------------------------------------------------------
    #
    multi method set ( 'port', Str:D $p ) {
      $!port = $p;
    }

    #---------------------------------------------------------------------------
    #
    method connect ( --> Neo4j::ErrorCode ) {
      $!status = Neo4j::SUCCESS;

      try {
        if ? $!sock {
          $!sock.close;
          $!sock = IO::Socket::INET;
        }

        $!sock .= new( :$!host, :$!port);
        CATCH {
          default {
            $!status = Neo4j::CONNECT-FAIL;
          }
        }
      }

      return $!status;
    }

    #---------------------------------------------------------------------------
    #
    method database ( Str:D $name --> Neo4j::Database ) {
      return Neo4j::Database.new( :$name, :connection(self));
    }

    #---------------------------------------------------------------------------
    #
    method send ( :$request ) {

      $!sock.print($request);
      my Str $result = $!sock.recv;

    }

    #---------------------------------------------------------------------------
    #
    multi method do ( 'transaction', Hash $statements) {
    }

    #---------------------------------------------------------------------------
    #
    multi method do ( 'commit', Hash $statements) {
    }

    #---------------------------------------------------------------------------
    #
    multi method do ( 'transaction-commit', Hash $statements) {
      my Neo4j::Command $cmd .= new;
      my Str $json = $cmd.encode($statements);
    }

    #---------------------------------------------------------------------------
    #
    multi method do ( 'roll-back', Hash $statements) {
    }

    #---------------------------------------------------------------------------
    #
    multi method do ( 'command', Hash $statements) {
    }
  }
}
