package ;

import tink.unit.TestBatch;
import tink.testrunner.Runner;

class Main {

    public static function main() {
        Runner.run(
            TestBatch.make([
                new basics.StringSpec(),
                new basics.FloatSpec(),
                new basics.IntSpec(),
                new basics.BoolSpec(),
                new basics.ArraySpec(),
                new basics.ObjectSpec(),
                new basics.RedefinedType(),
                new basics.VoidMethodSpec(),
                new basics.IntMethodSpec(),
                new classes.SingleBasicField(),
                new classes.NestedClass(),
                new classes.RecursiveClass(),
                new enums.SingleEnumField(),
                new enums.SingleEnumCtor(),
                new enums.RecursiveEnum(),
                new typedefs.SingleDefField(),
                new typedefs.NestedDef(),
                new typedefs.RecursiveDef(),
                new typedefs.LocalMethod(),
                new typedefs.LocalTypeParam(),
                new typedefs.Intersection(),
                new abstracts.RawAbstract(),
                new abstracts.RawComplexAbstract(),
                new abstracts.SingleAbstractField(),
                new abstracts.NestedAbstract(),

                // Not possible to support, afaik.
                //new abstracts.RecursiveAbstract(),
                new abstracts.FromCast(),
                new abstracts.FromCastField(),
                new abstracts.FromCastFieldComplex(),
                new methods.ManyArgs(),
                new methods.NestedMethod(),
                new parameters.ClsParams(),
                new parameters.EnmParams(),
                new parameters.DefParams(),
                new parameters.AbsParams(),
                new parameters.MethodParams(),
                /*new DefaultBasicSpec(),
                new DefaultEnumSpec(),
                new DefaultClassSpec(),*/
                //new DefaultTypedefSpec(),
            ])

        ).handle(Runner.exit);
    }

}
