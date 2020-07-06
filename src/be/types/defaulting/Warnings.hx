package be.types.defaulting;

enum abstract Warnings(String) to String {
    public static final MakeEmptyClass = 'The constructor of `::t::` will not be called. It will be created with `Type.createEmptyInstance` instead.';
}