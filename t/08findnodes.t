use Test;
BEGIN { plan tests=>36}
END {ok(0) unless $loaded;}
use XML::LibXML;
$loaded = 1;
ok($loaded);

# to test if findnodes works.
# i added findnodes to the node class, so a query can be started
# everywhere.

my $file    = "example/dromeds.xml";
$itervar    = undef;


# init the file parser
my $parser = XML::LibXML->new();
$dom    = $parser->parse_file( $file );

if ( defined $dom ) {
    # get the root document
    $elem   = $dom->getDocumentElement();
  
    # first very simple path starting at root
    my @list   = $elem->findnodes( "species" );
    ok( scalar(@list), 3 );

    # a simple query starting somewhere ...
    my $node = $list[0];
    my @slist = $node->findnodes( "humps" );
    ok( scalar(@slist), 1 );

    # find a single node
    @list   = $elem->findnodes( "species[\@name='Llama']" );
    ok( scalar( @list ), 1 );
  
    # find with not conditions
    @list   = $elem->findnodes( "species[\@name!='Llama']/disposition" );
    ok( scalar(@list), 2 );


    @list   = $elem->findnodes( 'species/@name' );
    ok( scalar @list && $list[0]->toString() eq ' name="Camel"' );

    my $x = XML::LibXML::Text->new( 1234 );
    if( defined $x ) {
        ok( $x->getData(), "1234" );
    }
    
    my $telem = $dom->createElement('test');
    $telem->appendWellBalancedChunk('<b>c</b>');

    $telem->iterator->iterate( sub { shift; $itervar.=$_[0]->getName(); } );
    ok( $itervar, 'testbtext' );
  
    finddoc($dom);
    ok(1);
}
ok( $dom );

# test to make sure that multiple array findnodes() returns
# don't segfault perl; it'll happen after the second one if it does
for (0..3) {
    my $doc = XML::LibXML->new->parse_string(
'<?xml version="1.0" encoding="UTF-8"?>
<?xsl-stylesheet type="text/xsl" href="a.xsl"?>
<a />');
    my @nds = $doc->findnodes("processing-instruction('xsl-stylesheet')");
}

$doc = $parser->parse_string(<<'EOT');
<a:foo xmlns:a="http://foo.com" xmlns:b="http://bar.com">
 <b:bar>
  <a:foo xmlns:a="http://other.com"/>
 </b:bar>
</a:foo>
EOT

my $root = $doc->getDocumentElement;
my @a = $root->findnodes('//a:foo');
ok(@a, 1);

@b = $root->findnodes('//b:bar');
ok(@b, 1);

@none = $root->findnodes('//b:foo');
@none = (@none, $root->findnodes('//foo'));
ok(@none, 0);

my @doc = $root->findnodes('document("example/test.xml")');
ok(@doc);
# warn($doc[0]->toString);

# this query should result an empty array!
my @nodes = $root->findnodes( "/humpty/dumpty" );
ok( scalar(@nodes), 0 );


my $docstring = q{
<foo xmlns="http://kungfoo" xmlns:bar="http://foo"/>
};
 $doc = $parser->parse_string( $docstring );
 $root = $doc->documentElement;

my @ns = $root->findnodes('namespace::*');
ok(scalar(@ns), 2 );

print "#bad xpaths\n";

my @badxpath = (
    'abc:::def',
    'foo///bar',
    '...',
    '/-',
               );

foreach my $xp ( @badxpath ) {
    eval { $res = $root->findnodes( $xp ); };
    ok($@);
    eval { $res = $root->find( $xp ); };
    ok($@);
    eval { $res = $root->findvalue( $xp ); };
    ok($@);
    eval { $res = $root->findnodes( encodeToUTF8( "iso-8859-1", $xp ) ); };
    ok($@);
    eval { $res = $root->find( encodeToUTF8( "iso-8859-1", $xp ) );};
    ok($@);
}

sub finddoc {
    my $doc = shift;
    return unless defined $doc;
    my $rn = $doc->documentElement;
    $rn->findnodes("/");
}
