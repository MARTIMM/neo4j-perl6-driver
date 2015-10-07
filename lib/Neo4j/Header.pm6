use v6;
use Neo4j;

package Neo4j {

  class Header {

    #---------------------------------------------------------------------------
    #
    method build-header( Str:D :$method, Str:D :$path, Hash:D :$hdata --> Str ) {

      my Str $header = "$method $path HTTP/1.1\n";
      for $hdata.kv -> $k, $v {
        $header ~= "$k: $v\n";
      }

      return $header;
    }
  }
}
