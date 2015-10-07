use v6;
use Neo4j;
use Neo4j::Header;
use Neo4j::User;
use JSON::Fast;

package Neo4j {

  class Command {

    has Neo4j::Header $.header;
    has Str $.command;
    has $!connection;

    has Neo4j::ErrorCode $.status;
    has Neo4j::ErrorCode $.http-status;
    has Str $.http-reason;

    #---------------------------------------------------------------------------
    #
    submethod BUILD ( :$connection where .^name eq 'Connection' ) {
      $!header .= new;
      $!connection = $connection;
    }

    #---------------------------------------------------------------------------
    #
    multi method build-command (
      Neo4j::User :$user,
      Str:D :$path,
      Hash:D :$body,
      Bool :$compress = False;
      --> Str
    ) {
      return self.build-command(
        :$user,
        :$path,
        :body(to-json($body)),
        :$compress
      );
    }

    #---------------------------------------------------------------------------
    #
    multi method build-command (
      Neo4j::User :$user,
      Str:D :$path,
      Str :$body = '',
      Bool :$compress = False;
      --> Str
    ) {

      my Hash $h;
      my Str $cmd = '';
      my $cmd-body = $body;
      if $compress {

      }

      $h<Host> = [~] $!connection.host, ':', $!connection.port;
      $h<Accept> = 'application/json; charset=UTF-8';
      $h<Content-Length> = $cmd-body.chars;
      $h<Content-Type> = 'application/json' if +$h<Content-Length>;

      if ?$user and my Str $auth = $user.b64-auth {
        $h<Authorization> = "Basic $auth";
      }

      my Str $method = +$h<Content-Length> ?? 'POST' !! 'GET';
      $cmd = $!header.build-header( :$method, :$path, :hdata($h)) ~ "\n";
      $cmd ~= $cmd-body if +$h<Content-Length>;

      return $!command = $cmd;
    }

    #---------------------------------------------------------------------------
    #
    multi method unravel-result ( Str:D $result --> Array ) {

      my Str $header-text;
      my Str $body-text;
      ( $header-text, $body-text) = $result.split( /"\n\n"/);

      my Hash $h;
      for $header-text.lines -> $l {
        if $l ~~ m:s/ ^ 'HTTP/' \d+ '.' \d+
                      $<status>=(\d+) $<reason>=(\w+)
                      $ / {

#say "Status: $/<status>, $/<reason>";
          $!http-reason = ~$/<reason>;
          given ~$/<status> {
            when m/^1\d\d/ {
              $!http-status = Neo4j::HTTP-INFORMATIONAL;
              $!status = Neo4j::SUCCESS;
            }

            when m/^2\d\d/ {
              $!http-status = Neo4j::HTTP-SUCCESS;
              $!status = Neo4j::SUCCESS;
            }

            when m/^3\d\d/ {
              $!http-status = Neo4j::HTTP-REDIRECTION;
              $!status = Neo4j::SUCCESS;
            }

            when m/^4\d\d/ {
              $!http-status = Neo4j::HTTP-CLIENT-ERROR;
              $!status = Neo4j::HTTP-ERROR;
            }

            when m/^5\d\d/ {
              $!http-status = Neo4j::HTTP-SERVER-ERROR;
              $!status = Neo4j::HTTP-ERROR;
            }
          }
        }

        else {
          my Str $k;
          my Str $v;
          ( $k, $v) = $l.split( /':'\s*/, 2);
          $h{$k} = $v;
        }
      }

      return [ $h, from-json($body-text)];
    }
  }
}
