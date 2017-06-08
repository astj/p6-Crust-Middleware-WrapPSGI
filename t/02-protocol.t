use v6.c;
use Test;
use Crust::Builder;
use HTTP::Message::PSGI;
use Crust::Middleware::PromiseWrapper;

my $app = builder {
    enable "PromiseWrapper";
    -> %env {
        (200, [ 'Content-Type' => 'text/plain' ], [ 'Hello World' ]);
    };
};

my $req = HTTP::Request.new(GET => "http://localhost/hello").to-psgi;

subtest {
    $req<p6w.protocol.support> = <request-response>.SetHash;
    $req<p6w.protocol.enabled>:delete;

    my $res = $app($req);
    await $res;
    is $req<p6w.protocol.enabled>, <request-response>.SetHash;
}, 'request-response only';

subtest {
    $req<p6w.protocol.support> = <request-response psgi>.SetHash;
    $req<p6w.protocol.enabled>:delete;

    my $res = $app($req);
    await $res;
    is $req<p6w.protocol.enabled>, <request-response>.SetHash;
}, 'other protocols are removed ';

subtest {
    my $res = $app($req);
    $req<p6w.protocol.support>:delete;
    $req<p6w.protocol.enabled>:delete;
    lives-ok {
        await $res;
    };
}, 'works even if server does not set protocol ';

done-testing;
