package ceylon.language;

import com.redhat.ceylon.compiler.java.metadata.Defaulted;
import com.redhat.ceylon.compiler.java.metadata.Name;
import com.redhat.ceylon.compiler.java.runtime.model.ReifiedType;
import com.redhat.ceylon.compiler.java.runtime.model.TypeDescriptor;

public final class Integer
    implements ReifiedType, 
               java.io.Serializable, 
               java.lang.Comparable<Integer> {

    private static final long serialVersionUID = 3611850372864102202L;

    static final long TWO_FIFTY_THREE = 1L << 53;

    
    public final static TypeDescriptor $TypeDescriptor$ = 
            TypeDescriptor.klass(Integer.class);

    public static long smallest(@Name("x") long x, @Name("y") long y) {
        return Math.min(x, y);
    }
    
    public static long largest(@Name("x") long x, @Name("y") long y) {
        return Math.max(x, y);
    }
    
    
    final long value;

    @SharedAnnotation$annotation$
    public Integer(@Name("integer") long integer) {
        value = integer;
    }

    
    public static Integer instance(long l) {
        return new Integer(l);
    }

    
    public long longValue() {
        return value;
    }
    
    
    public Integer plus(@Name("other") Integer other) {
        return instance(value + other.value);
    }

    
    public static long plus(long value, long otherValue) {
        return value + otherValue;
    }

    
    public Integer minus(@Name("other") Integer other) {
        return instance(value - other.value);
    }

    
    public static long minus(long value, long otherValue) {
        return value - otherValue;
    }

    
    public Integer times(@Name("other") Integer other) {
        return instance(value * other.value);
    }

    
    public static long times(long value, long otherValue) {
        return value * otherValue;
    }

    
    public Integer divided(@Name("other") Integer other) {
        return instance(value / other.value);
    }

    
    public static long divided(long value, long otherValue) {
        return value / otherValue;
    }

    private static final long POWER_BY_SQUARING_BREAKEVEN = 6;

    private static long powerBySquaring(long base, long power) {
        long result = 1;
        long x = base;
        while (power != 0) {
            if ((power & 1L) == 1L) {
                result *= x;
                power -= 1;
            }
            x *= x;
            power /= 2;
        }
        return result;
    }

    private static long powerByMultiplying(long base, long power) {
        long result = 1;
        while (power > 0) {
            result *= base;
            power--;
        }
        return result;
    }

    
    public Integer power(@Name("other") Integer other) {
        return instance(power(value, other.value));
    }

    
    public static long power(long value, long otherValue) {
        long power = otherValue;
        if (value == -1) {
            return power % 2 == 0 ? 1L : -1L;
        }
        else if (value == 1) {
            return 1L;
        }
        else if (power < 0) {
            throw new AssertionError(value + "^" + power + 
                    " cannot be represented as an Integer");
        }
        else if (power == 0) {
            return 1L;
        }
        else if (power == 1) {
            return value;
        }
        else if (power >= POWER_BY_SQUARING_BREAKEVEN) {
            return powerBySquaring(value, power);
        }
        else {
            return powerByMultiplying(value, power);
        }
    }
    
    private static int powerBySquaring(int base, int power) {
        int result = 1;
        int x = base;
        while (power != 0) {
            if ((power & 1) == 1) {
                result *= x;
                power -= 1;
            }
            x *= x;
            power /= 2;
        }
        return result;
    }

    private static int powerByMultiplying(int base, int power) {
        int result = 1;
        while (power > 0) {
            result *= base;
            power--;
        }
        return result;
    }
    
    
    public static long $power$(long value, long otherValue) {
        return power(value, otherValue);
    }
    
    
    public static int $power$(int value, int otherValue) {
        int power = otherValue;
        if (value == -1) {
            return power % 2 == 0 ? 1 : -1;
        }
        else if (value == 1) {
            return 1;
        }
        else if (power < 0) {
            throw new AssertionError(value + "^" + power + 
                    " cannot be represented as an Integer");
        }
        else if (power == 0) {
            return 1;
        }
        else if (power == 1) {
            return value;
        }
        else if (power >= POWER_BY_SQUARING_BREAKEVEN) {
            return powerBySquaring(value, power);
        }
        else {
            return powerByMultiplying(value, power);
        }
    }

    
    public Float plus(Float other) {
        return Float.instance(value + other.value);
    }

    
    public static double plus(long value, double otherValue) {
        return value + otherValue;
    }

    
    public Float minus(Float other) {
        return Float.instance(value - other.value);
    }

    
    public static double minus(long value, double otherValue) {
        return value - otherValue;
    }

    
    public Float times(Float other) {
        return Float.instance(value * other.value);
    }

    
    public static double times(long value, double otherValue) {
        return value * otherValue;
    }

    
    public Float divided(Float other) {
        return Float.instance(value / other.value);
    }

    
    public static double divided(long value, double otherValue) {
        return value / otherValue;
    }

    
    public Float power(Float other) {
        return Float.instance(Math.pow(value, other.value)); // FIXME: ugly
    }

    
    public static double power(long value, double otherValue) {
        return Math.pow(value, otherValue); // FIXME: ugly
    }
    
    
    public static double $power$(long value, double otherValue) {
        return Math.pow(value, otherValue); // FIXME: ugly
    }

    
    public Integer getMagnitude() {
        return instance(Math.abs(value));
    }

    
    public static long getMagnitude(long value) {
        return Math.abs(value);
    }

    
    
    public Integer getFractionalPart() {
        return instance(0);
    }

    
    public static long getFractionalPart(long value) {
        return 0;
    }

    
    
    public Integer getWholePart() {
        return this;
    }

    
    public static long getWholePart(long value) {
        return value;
    }

    
    
    public boolean getPositive() {
        return value > 0;
    }

    
    public static boolean getPositive(long value) {
        return value > 0;
    }

    
    
    public boolean getNegative() {
        return value < 0;
    }

    
    public static boolean getNegative(long value) {
        return value < 0;
    }

    
    
    public long getSign() {
        if (value > 0)
            return 1;
        if (value < 0)
            return -1;
        return 0;
    }

    
    public static long getSign(long value) {
        if (value > 0)
            return 1;
        if (value < 0)
            return -1;
        return 0;
    }

    
    public Integer remainder(@Name("other") Integer other) {
        return instance(value % other.value);
    }

    
    public static long remainder(long value, long otherValue) {
        return value % otherValue;
    }

    
    public Integer modulo(@Name("modulus") Integer modulus) {
        return instance(modulo(value, modulus.value));
    }

    
    public static long modulo(long value, long modulus) {
        if(modulus < 0)
            throw new AssertionError("modulus must be positive: "+modulus);
        long ret = value % modulus;
        if(ret < 0)
            return ret + modulus;
        return ret;
    }

    
    public final boolean divides(@Name("other") Integer other) {
        return other.value % value == 0;
    }

    
    public static boolean divides(long value, long otherValue) {
        return otherValue % value == 0;
    }

    
    public Integer getNegated() {
        return instance(-value);
    }

    
    public static long getNegated(long value) {
        return -value;
    }

    @Override 
    public int compareTo(Integer other) {
        return Long.compare(value, other.value);
    }

    @Override
    public java.lang.String toString() {
        return java.lang.Long.toString(value);
    }

    
    public static java.lang.String toString(long value) {
        return java.lang.Long.toString(value);
    }

    // Enumerable
    
    
    public static long neighbour(long value, long offset) {
        long neighbour = value+offset;
        //Overflow iff both arguments have the opposite sign of the result
        if (((value^neighbour) & (offset^neighbour)) < 0) {
            throw new OverflowException(value + " has no neighbour with offset " + offset);
        }
        return neighbour;
    }

    
    public Integer neighbour(@Name("offset") long offset) {
        return instance(neighbour(value,offset));
    }

    
    public static long offset(long value, long other) {
        long offset = value-other;
        //Overflow iff the arguments have different signs and
        //the sign of the result is different than the sign of x
        if (((value^other) & (value^offset)) < 0) {
            throw new OverflowException(
                    "offset from " + value + " to " + other + " cannot be represented as a 64 bit integer.");
        }
        return offset;
    }

    
    public long offset(@Name("other") Integer other) {
        return offset(value, other.value);
    }

    
    public static long offsetSign(long value, long other) {
        if (value>other) {
            return 1;
        }
        else if (value<other) {
            return -1;
        }
        else {
            return 0;
        }
    }

    
    public long offsetSign(@Name("other") Integer other) {
        return offsetSign(value, other.value);
    }

    // Conversions between numeric types
    
    public double getFloat() {
        return getFloat(value);
    }

    
    public static double getFloat(long value) {
        if (value <= -TWO_FIFTY_THREE || TWO_FIFTY_THREE <= value) {
            throw new OverflowException(value + " cannot be coerced into a 64 bit floating point value");
        }
        else {
        	return (double) value;
        }
    }

    public double getNearestFloat() {
        return (double) value;
    }

    
    public static double getNearestFloat(long value) {
        return (double) value;
    }

    
    public byte getByte() {
        return getByte(value);
    }

    
    public static byte getByte(long value) {
        return (byte) value;
    }

    public boolean getEven() {
        return (value&1)==0;
    }

    public static boolean getEven(long value) {
        return (value&1)==0;
    }

    
    
    public boolean getUnit() {
        return value==1;
    }

    
    public static boolean getUnit(long value) {
        return value==1;
    }

    
    
    public boolean getZero() {
        return value==0;
    }

    
    public static boolean getZero(long value) {
        return value==0;
    }

    
    
    public Integer getPredecessor() {
        return Integer.instance(value - 1);
    }

    
    public static long getPredecessor(long value) {
        return value - 1;
    }

    
    
    public Integer getSuccessor() {
        return Integer.instance(value + 1);
    }

    
    public static long getSuccessor(long value) {
        return value + 1;
    }

    
    public boolean equals(@Name("that") java.lang.Object that) {
        return equals(value, that);
    }

    
    public static boolean equals(long value, java.lang.Object that) {
        if (that instanceof Integer) {
            return value == ((Integer)that).value;
        }
        else if (that instanceof Float) {
            return value == ((Float) that).value 
                    && value > -TWO_FIFTY_THREE 
                    && value < TWO_FIFTY_THREE;
        }
        else {
            return false;
        }
    }

    @Override 
    public int hashCode() {
        return (int)(value ^ (value >>> 32));
    }

    
    public static int hashCode(long value) {
        return (int)(value ^ (value >>> 32));
    }

    
    public Integer getNot() {
        return instance(~value);
    }
    
    
    public static long getNot(long value){
        return ~value;
    }

    
    public Integer leftLogicalShift(@Name("shift") long shift) {
        return instance(value << shift);
    }
    
    
    public static long leftLogicalShift(long value, long shift) {
        return value << shift;
    }

    public Integer rightLogicalShift(@Name("shift") long shift) {
        return instance(value >>> shift);
    }
    
    public static long rightLogicalShift(long value, long shift) {
        return value >>> shift;
    }

    
    public Integer rightArithmeticShift(@Name("shift") long shift) {
        return instance(value >> shift);
    }
    
    
    public static long rightArithmeticShift(long value, long shift) {
        return value >> shift;
    }

    
    public Integer and(@Name("other") Integer other) {
        return instance(value & other.value);
    }
    
    
    public static long and(long value, long other){
        return value & other;
    }

    
    public Integer or(@Name("other") Integer other) {
        return instance(value | other.value);
    }
    
    
    public static long or(long value, long other){
        return value | other;
    }

    
    public Integer xor(@Name("other") Integer other) {
        return instance(value ^ other.value);
    }
    
    
    public static long xor(long value, long other){
        return value ^ other;
    }

    
    public boolean get(@Name("index") long index) {
        return get(value, index);
    }

    
    public static boolean get(long value, long index) {
        if (index < 0 || index > 63) {
            return false;
        }
        long mask = 1l << index;
        return (value & mask) != 0;
    }
    
    
    
    public Integer set(long index) {
        return instance(set(value, index));
    }

    
    public Integer set(@Name("index") long index, 
            @Name("bit") @Defaulted boolean bit) {
        return instance(set(value, index, bit));
    }

    
    
    public boolean set$bit(long index) {
        return true;
    }

    
    public static long set(long value, long index) {
        return set(value, index, true);
    }

    
    public static long set(long value, long index, boolean bit) {
        if (index < 0 || index > 63) {
            return value;
        }
        long mask = 1l << index;
        return bit ? value | mask : value & ~mask;
    }

    
    public Integer clear(@Name("index") long index) {
        return instance(clear(value, index));
    }

    
    public static long clear(long value, long index) {
        if (index < 0 || index > 63) {
            return value;
        }
        long mask = 1l << index;
        return value & ~mask;
    }

    
    public Integer flip(@Name("index") long index) {
        return instance(flip(value, index));
    }

    
    public static long flip(long value, long index) {
        if (index < 0 || index > 63) {
            return value;
        }
        long mask = 1l << index;
        return value ^ mask;
    }

    
    @Override
    public TypeDescriptor $getType$() {
        return $TypeDescriptor$;
    }
    
    
    public static boolean largerThan(long value, Integer other) {
    	return value>other.value;
    }

    
    public static boolean largerThan(long value, long other) {
        return value>other;
    }
    
    
    public boolean largerThan(@Name("other") Integer other) {
    	return value>other.value;
    }

    
    public static boolean notSmallerThan(long value, Integer other) {
    	return value>=other.value;
    }

    
    public static boolean notSmallerThan(long value, long other) {
        return value>=other;
    }

    
    public boolean notSmallerThan(@Name("other") Integer other) {
    	return value>=other.value;
    }

    
    public static boolean smallerThan(long value, Integer other) {
    	return value<other.value;
    }

    
    public static boolean smallerThan(long value, long other) {
        return value<other;
    }

    
    public boolean smallerThan(@Name("other") Integer other) {
    	return value<other.value;
    }

    
    public static boolean notLargerThan(long value, Integer other) {
    	return value<=other.value;
    }

    
    public static boolean notLargerThan(long value, long other) {
        return value<=other;
    }

    
    public boolean notLargerThan(@Name("other") Integer other) {
    	return value<=other.value;
    }

    
    public Integer timesInteger(@Name("integer") long integer) {
    	return instance(value*integer);
    }
    
    
    public static long timesInteger(long value, long integer) {
    	return value*integer;
    }
    
    
    public Integer plusInteger(@Name("integer") long integer) {
    	return instance(value+integer);
    }
    
    
    public static long plusInteger(long value, long integer) {
    	return value+integer;
    }
    
    
    public Integer powerOfInteger(@Name("integer") long integer) {
        return instance(power(value,integer));
    }
    
    
    public static long powerOfInteger(long value, long integer) {
        return power(value,integer);
    }
    
    
    public static Integer valueOf(java.lang.String string) {
        return instance(java.lang.Long.parseLong(string));
    }
    
}
