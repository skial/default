package ;

import tink.unit.TestBatch;
import tink.testrunner.Runner;

class Main {

    public static function main() {
        Runner.run(
            TestBatch.make([
                /*new basics.StringSpec(),
                new basics.FloatSpec(),
                new basics.IntSpec(),
                new basics.BoolSpec(),
                new basics.RedefinedType(),
                new classes.SingleBasicField(),
                new classes.NestedClass(),
                new classes.RecursiveClass(),
                new enums.SingleEnumField(),
                new enums.SingleEnumCtor(),
                new enums.RecursiveEnum(),
                new typedefs.SingleDefField(),
                new typedefs.NestedDef(),
                new typedefs.RecursiveDef(),*/
                new abstracts.SingleAbstractField(),
                /*new parameters.ClsParams(),
                new parameters.EnmParams(),
                new parameters.DefParams(),
                new parameters.AbsParams(),*/
                /*new DefaultBasicSpec(),
                new DefaultEnumSpec(),
                new DefaultClassSpec(),
                new DefaultTypedefSpec(),*/
            ])

        ).handle(Runner.exit);
    }

}
