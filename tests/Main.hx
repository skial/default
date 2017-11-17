package ;

import utest.Runner;
import utest.ui.Report;

class Main {

    public static function main() {
        var runner = new Runner();
        runner.addCase( new DefaultSpec() );
        Report.create( runner );
        runner.run();
    }

}
