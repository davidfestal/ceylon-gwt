package ceylon.language;

public class OverflowException extends Exception {
    private static final long serialVersionUID = 1L;

    public OverflowException() {
        super();
    }
    
    public OverflowException(java.lang.String message) {
        super(String.instance(message));
    }
}
