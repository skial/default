package ;

typedef TFoo = String;

typedef Twins = {
    var a:TFoo;
    var b:TFoo;
}

typedef TBar = {
    var twins:Twins;
}