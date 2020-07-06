package be.types.defaulting;

enum abstract Errors(String) to String {
    public static final Report = 'Please report with minimal example at https://github.com/skial/default/issues.';
    public static final MethodNotDynamic = 'Cannot rebind this method : please use \'dynamic\' before method declaration.';
    public static final UnexpectedExpression = 'Unexpected expression. $Report';
    public static final NoExpression = 'No expression constructed. $Report';
    public static final MissingType = 'Cannot find type ::t::.';
    public static final MissingSubType = 'Cannot find subtype ::t::.';
    public static final CircularDependency = 'Potential circular dependency between ::a:: and ::b:: detected. Circular dependencies are not supported in Default.';
}