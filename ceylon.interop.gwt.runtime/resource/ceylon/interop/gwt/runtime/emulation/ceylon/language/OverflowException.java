package ceylon.language;

public class OverflowException extends Exception {
    public OverflowException() {
        super();
    }
    
    public OverflowException(java.lang.String message) {
        super(String.instance(message));
    }
}
