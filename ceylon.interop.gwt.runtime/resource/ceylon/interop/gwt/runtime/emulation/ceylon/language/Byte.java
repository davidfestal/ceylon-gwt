package ceylon.language;

import com.redhat.ceylon.compiler.java.metadata.Defaulted;
import com.redhat.ceylon.compiler.java.metadata.Name;
import com.redhat.ceylon.compiler.java.runtime.model.ReifiedType;
import com.redhat.ceylon.compiler.java.runtime.model.TypeDescriptor;

public final class Byte implements 
        ReifiedType, 
        java.io.Serializable {
    
    private static final long serialVersionUID = -8113399654156430108L;
    
    
    public final static TypeDescriptor $TypeDescriptor$ = TypeDescriptor.klass(Byte.class);

    
    final byte value;
    
    public Byte(@Name("congruent") long congruent) {
        value = (byte) congruent;
    }
    
    
    public Byte(byte value) {
        this.value = value;
    }
    
    
    public static Byte instance(byte value) {
        return new Byte(value);
    }
    
    
    public byte byteValue() {
        return value;
    }
    
    
    @Override
    public TypeDescriptor $getType$() {
        return $TypeDescriptor$;
    }
    
    
    public boolean getEven() {
        return (value & 1) == 0;
    }

    
    public static boolean getEven(byte value) {
        return (value & 1) == 0;
    }

    
    public boolean getZero() {
        return value == 0;
    }

    
    public static boolean getZero(byte value) {
        return value == 0;
    }

    
    public boolean getUnit() {
        return value == 1;
    }

    
    public static boolean getUnit(byte value) {
        return value == 1;
    }

    
    public Byte getNegated() {
        return new Byte((byte)-value);
    }

    
    public static byte getNegated(byte value) {
        return (byte)-value;
    }

    public Byte plus(@Name("other") Byte other) {
        return new Byte((byte) (value+other.value));
    }

    
    public static byte plus(byte value, byte other) {
        return (byte) (value+other);
    }

    
    public Byte minus(@Name("other") Byte other) {
        return new Byte((byte) (value-other.value));
    }

    
    public static byte minus(byte value, byte other) {
        return (byte) (value-other);
    }

    public Byte and(@Name("other") Byte other) {
        return new Byte((byte) (value & other.value));
    }

    
    public static byte and(byte value, byte other) {
        return (byte) (value & other);
    }

    public Byte or(@Name("other") Byte other) {
        return new Byte((byte) (value | other.value));
    }

    
    public static byte or(byte value, byte other) {
        return (byte) (value | other);
    }

    public Byte xor(@Name("other") Byte other) {
        return new Byte((byte) (value ^ other.value));
    }

    public static byte xor(byte value, byte other) {
        return (byte) (value ^ other);
    }

    
    public Byte getNot() {
        return new Byte((byte) ~value);
    }
    
    
    public static byte getNot(byte value) {
        return (byte) ~value;
    }
    
    public Byte leftLogicalShift(@Name("shift") long shift) {
        return new Byte((byte) (value<<(shift&7)));
    }

    
    public static byte leftLogicalShift(byte value, long shift) {
        return (byte) (value<<(shift&7));
    }

    public Byte rightArithmeticShift(@Name("shift") long shift) {
        return new Byte((byte) (value>>(shift&7)));
    }

    
    public static byte rightArithmeticShift(byte value, long shift) {
        return (byte) (value>>(shift&7));
    }

    public Byte rightLogicalShift(@Name("shift") long shift) {
        return new Byte((byte) ((0xff&value)>>>(shift&7)));
    }

    
    public static byte rightLogicalShift(byte value, long shift) {
        return (byte) ((0xff&value)>>>(shift&7));
    }

    public Byte clear(@Name("index") long index) {
        if (index < 0 || index > 7) {
            return this;
        }
        int mask = 1 << index;
        return new Byte((byte) ((0xff&value) & ~mask));
    }

    
    public static byte clear(byte value, long index) {
        if (index < 0 || index > 7) {
            return value;
        }
        int mask = 1 << index;
        return (byte) ((0xff&value) & ~mask);
    }

    public Byte flip(@Name("index") long index) {
        if (index < 0 || index > 7) {
            return this;
        }
        int mask = 1 << index;
        return new Byte((byte) ((0xff&value) ^ mask));
    }

    
    public static byte flip(byte value, long index) {
        if (index < 0 || index > 7) {
            return value;
        }
        int mask = 1 << index;
        return (byte) ((0xff&value) ^ mask);
    }

    
    public Byte set(long index) {
        return set(index, true);
    }

    
    public static byte set(byte value, long index) {
        return set(value, index, true);
    }

    public Byte set(@Name("index") long index, 
            @Name("bit") @Defaulted boolean bit) {
        if (index < 0 || index > 7) {
            return this;
        }
        int mask = 1 << index;
        int masked = bit ? 
                (0xff&value) | mask : 
                (0xff&value) & ~mask;
        return new Byte((byte) masked);
    }

    
    public static byte set(byte value, long index, boolean bit) {
        if (index < 0 || index > 7) {
            return value;
        }
        int mask = 1 << index;
        int masked = bit ? 
                (0xff&value) | mask : 
                (0xff&value) & ~mask;
        return (byte) masked;
    }

    
    public boolean set$bit(long index) {
        return true;
    }

    public boolean get(@Name("index") long index) {
        if (index < 0 || index > 7) {
            return false;
        }
        int mask = 1 << index;
        return ((0xff&value) & mask) != 0;
    }

    
    public static boolean get(byte value, long index) {
        if (index < 0 || index > 7) {
            return false;
        }
        int mask = 1 << index;
        return ((0xff&value) & mask) != 0;
    }
    
    public long getUnsigned() {
        return 0xff&value;
    }
    
    
    public static long getUnsigned(byte value) {
        return 0xff&value;
    }

    
    public long getSigned() {
        return value;
    }
    
    
    public static long getSigned(byte value) {
        return value;
    }
    
    public boolean equals(@Name("that") java.lang.Object obj) {
        if (obj instanceof Byte) {
            return value==((Byte) obj).value;
        }
        else {
            return false;
        }
    }
    
    
    public static boolean equals(byte value, java.lang.Object obj) {
        if (obj instanceof Byte) {
            return value==((Byte) obj).value;
        }
        else {
            return false;
        }
    }
    
    
    public Byte getPredecessor() {
        return new Byte((byte) (value-1));
    }
    
    
    public static byte getPredecessor(byte value) {
        return (byte) (value-1);
    }
    
    
    public Byte getSuccessor() {
        return new Byte((byte) (value+1));
    }
    
    
    public static byte getSuccessor(byte value) {
        return (byte) (value+1);
    }
    
    @Override
    
    public int hashCode() {
        return value;
    }
    
    
    public static int hashCode(byte value) {
        return value;
    }
    
    @Override
    
    public java.lang.String toString() {
        return Integer.toString(0xff&value);
    }
    
    
    public static java.lang.String toString(byte value) {
        return Integer.toString(0xff&value);
    }

    public Byte neighbour(@Name("offset") long offset) {
        return new Byte(((byte) (value + offset)));
    }
    
    
    public static byte neighbour(byte value, long offset) {
        return (byte) (value + offset);
    }

    public long offset(@Name("other") Byte other) {
        return ((byte) (value - other.value)) & 0xff;
    }

    
    public static long offset(byte value, byte other) {
        return ((byte) (value - other)) & 0xff;
    }

    public long offsetSign(@Name("other") Byte other) {
        return value==other.value ? 0 : 1;
    }

    
    public static long offsetSign(byte value, byte other) {
        return value==other ? 0 : 1;
    }
    
    
    public static Byte valueOf(java.lang.String string) {
        return instance(java.lang.Byte.parseByte(string));
    }
}
