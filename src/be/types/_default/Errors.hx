package be.types._default;

enum abstract Errors(String) to String {
    public static final CircularDependency = 'Potential circular dependency between ::a:: and ::b:: detected. Circular dependencies are not supported in Default.';
}