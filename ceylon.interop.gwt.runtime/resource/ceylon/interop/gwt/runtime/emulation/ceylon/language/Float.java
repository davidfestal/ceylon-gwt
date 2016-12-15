package ceylon.language;

import com.redhat.ceylon.compiler.java.Util;
import com.redhat.ceylon.compiler.java.metadata.Ceylon;
import com.redhat.ceylon.compiler.java.metadata.Class;
import com.redhat.ceylon.compiler.java.metadata.Defaulted;
import com.redhat.ceylon.compiler.java.metadata.Ignore;
import com.redhat.ceylon.compiler.java.metadata.Name;
import com.redhat.ceylon.compiler.java.metadata.SatisfiedTypes;
import com.redhat.ceylon.compiler.java.metadata.Transient;
import com.redhat.ceylon.compiler.java.metadata.TypeInfo;
import com.redhat.ceylon.compiler.java.metadata.TypeParameter;
import com.redhat.ceylon.compiler.java.metadata.TypeParameters;
import com.redhat.ceylon.compiler.java.metadata.ValueType;
import com.redhat.ceylon.compiler.java.runtime.model.ReifiedType;
import com.redhat.ceylon.compiler.java.runtime.model.TypeDescriptor;

public final class Float
    implements ReifiedType, 
               java.io.Serializable, 
               java.lang.Comparable<Float> {

    private static final long serialVersionUID = 8699090544995758140L;

    private static final double TWO_FIFTY_TWO = (double) (1L << 52);

    
    public final static TypeDescriptor $TypeDescriptor$ = 
            TypeDescriptor.klass(Float.class);

    public static double smallest(@Name("x") double x, @Name("y") double y) {
        return Math.min(x, y);
    }
    
    public static double largest(@Name("x") double x, @Name("y") double y) {
        return Math.max(x, y);
    }
    
    
    final double value;
    
    @SharedAnnotation$annotation$
    public Float(@Name("float") double f) {
        value = f;
    }
    
    
    public static Float instance(double d) {
        return new Float(d);
    }
    
    
    public double doubleValue() {
        return value;
    }
    
    public Float plus(@Name("other") Float other) {
        return instance(value + other.value);
    }
    
    
    public static double plus(double value, double otherValue) {
        return value + otherValue;
    }
    
    public Float minus(@Name("other") Float other) {
        return instance(value - other.value);
    }
    
    
    public static double minus(double value, double otherValue) {
        return value - otherValue;
    }
    
    
    public Float times(@Name("other") Float other) {
        return instance(value * other.value);
    }
    
    
    public static double times(double value, double otherValue) {
        return value * otherValue;
    }
    
    
    public Float divided(@Name("other") Float other) {
        return instance(value / other.value);
    }
    
    
    public static double divided(double value, double otherValue) {
        return value / otherValue;
    }
    
    
    public Float power(@Name("other") Float other) {
        return instance(power(value, other.value));
    }
    
    
    public static double $power$(double value, double otherValue) {
        return power(value, otherValue);
    }
    
    
    public static float $power$(float value, float otherValue) {
        if (otherValue==0.0F && 
                !java.lang.Float.isNaN(value)) {
            return 1.0F;
        }
        else if (otherValue==1.0F) {
            return value;
        }
        else if (otherValue==2.0F) {
            return value*value;
        }
        else if (otherValue==3.0F) {
            return value*value*value;
        }
        else if (otherValue==4.0F) {
            float sqr = value*value;
            return sqr*sqr;
        }
        else if (otherValue==5.0F) {
            float sqr = value*value;
            return sqr*sqr*value;
        }
        else if (otherValue==6.0F) {
            float sqr = value*value;
            return sqr*sqr*sqr;
        }
        //TODO: other positive integer powers for which
        //      multiplying is faster than pow()
        else if (otherValue==0.5F) {
            return (float)Math.sqrt(value);
        }
        else if (otherValue==0.25F) {
            return (float)Math.sqrt(Math.sqrt(value));
        }
        else if (otherValue==-1.0F) {
            return 1.0F/value;
        }
        else if (otherValue==-2.0F) {
            return 1.0F/value/value;
        }
        else if (otherValue==-3.0F) {
            return 1.0F/value/value/value;
        }
        else if (otherValue==-4.0F) {
            float sqr = value*value;
            return 1/sqr/sqr;
        }
        else if (otherValue==-5.0F) {
            float sqr = value*value;
            return 1/sqr/sqr/value;
        }
        else if (otherValue==-6.0F) {
            float sqr = value*value;
            return 1/sqr/sqr/sqr;
        }
        else if (otherValue==-0.5F) {
            return (float)(1.0/Math.sqrt(value));
        }
        else if (otherValue==-0.25F) {
            return (float)(1.0/Math.sqrt(Math.sqrt(value)));
        }
        else if (value==1.0F) {
            return 1.0F;
        }
        else if (value==-1.0F && 
                (otherValue == java.lang.Float.POSITIVE_INFINITY || 
                 otherValue == java.lang.Float.NEGATIVE_INFINITY)) {
            return 1.0F;
        }
        else {
            //NOTE: this function is _really_ slow!
            return (float)Math.pow(value, otherValue);
        }
    }
    
    
    public static double power(double value, double otherValue) {
        if (otherValue==0.0 && 
                !Double.isNaN(value)) {
            return 1.0;
        }
        else if (otherValue==1.0) {
            return value;
        }
        else if (otherValue==2.0) {
            return value*value;
        }
        else if (otherValue==3.0) {
            return value*value*value;
        }
        else if (otherValue==4.0) {
            double sqr = value*value;
            return sqr*sqr;
        }
        else if (otherValue==5.0) {
            double sqr = value*value;
            return sqr*sqr*value;
        }
        else if (otherValue==6.0) {
            double sqr = value*value;
            return sqr*sqr*sqr;
        }
        //TODO: other positive integer powers for which
        //      multiplying is faster than pow()
        else if (otherValue==0.5) {
            return Math.sqrt(value);
        }
        else if (otherValue==0.25) {
            return Math.sqrt(Math.sqrt(value));
        }
        else if (otherValue==-1.0) {
            return 1.0/value;
        }
        else if (otherValue==-2.0) {
            return 1.0/value/value;
        }
        else if (otherValue==-3.0) {
            return 1.0/value/value/value;
        }
        else if (otherValue==-4.0) {
            double sqr = value*value;
            return 1/sqr/sqr;
        }
        else if (otherValue==-5.0) {
            double sqr = value*value;
            return 1/sqr/sqr/value;
        }
        else if (otherValue==-6.0) {
            double sqr = value*value;
            return 1/sqr/sqr/sqr;
        }
        else if (otherValue==-0.5) {
            return 1.0/Math.sqrt(value);
        }
        else if (otherValue==-0.25) {
            return 1.0/Math.sqrt(Math.sqrt(value));
        }
        else if (value==1.0) {
            return 1.0;
        }
        else if (value==-1.0 && 
                (otherValue == Double.POSITIVE_INFINITY || 
                 otherValue == Double.NEGATIVE_INFINITY)) {
            return 1.0;
        }
        else {
            //NOTE: this function is _really_ slow!
            return Math.pow(value, otherValue);
        }
    }
    
    
    public Float plus(Integer other) {
        return instance(value + other.value);
    }
    
    
    public static double plus(double value, long otherValue) {
        return value + otherValue;
    }
    
    
    public Float minus(Integer other) {
        return instance(value - other.value);
    }
    
    
    public static double minus(double value, long otherValue) {
        return value - otherValue;
    }
    
    
    public Float times(Integer other) {
        return instance(value * other.value);
    }
    
    
    public static double times(double value, long otherValue) {
        return value * otherValue;
    }
    
    
    public Float divided(Integer other) {
        return instance(value / other.value);
    }
    
    
    public static double divided(double value, long otherValue) {
        return value / otherValue;
    }
    
    
    public Float power(Integer other) {
        return instance(powerOfInteger(value, other.value));
    }
    
    
    public static double power(double value, long otherValue) {
        return powerOfInteger(value, otherValue);
    }
    
    
    public static double $power$(double value, long otherValue) {
        return powerOfInteger(value, otherValue);
    }

    public Float getMagnitude() {
        return instance(Math.abs(value));
    }
    
    
    public static double getMagnitude(double value) {
        return Math.abs(value);
    }
    
    
    public Float getFractionalPart() {
        double fractionalPart = getFractionalPart(value);
        if (fractionalPart != 0 && fractionalPart == value) {
            return this;
        }
        return instance(fractionalPart);
    }

    
    public static double getFractionalPart(double value) {
        if (value <= -TWO_FIFTY_TWO) {
            return -0d;
        }
        else if (value >= TWO_FIFTY_TWO) {
            return 0d;
        }
        else if (Double.isNaN(value)) {
            return Double.NaN;
        }
        else {
            double result = value - (long) value;
            if (result == 0 && (1/value) < 0) {
                return -0d;
            }
            else {
                return result;
            }
        }
    }

    
    public Float getWholePart() {
        double wholePart = getWholePart(value);
        if (wholePart != 0 && wholePart == value) {
            return this;
        }
        return instance(wholePart);
    }

    
    public static double getWholePart(double value) {
        if (value <= -TWO_FIFTY_TWO || 
            value >= TWO_FIFTY_TWO) {
            return value;
        }
        else if (Double.isNaN(value)) {
            return Double.NaN;
        }
        else {
            long result = (long) value;
            if (result == 0 && (1/value) < 0) {
                return -0.0d;
            }
            else {
                return result;
            }
        }
    }

    
    
    public boolean getPositive() {
        return value > 0;
    }
    
    
    public static boolean getPositive(double value) {
        return value > 0;
    }
    
    
    
    public boolean getNegative() {
        return value < 0;
    }
    
    
    public static boolean getNegative(double value) {
        return value < 0;
    }
    
    public long getSign() {
        if (value > 0)
            return 1;
        if (value < 0)
            return -1;
        return 0;
    }	
    
    
    public static long getSign(double value) {
        if (value > 0)
            return 1;
        if (value < 0)
            return -1;
        return 0;
    }   
    
    
    public Float getNegated() {
        return instance(-value);
    }
    
    
    public static double getNegated(double value) {
        return -value;
    }
    
    public int compareTo(Float other) {
        return Double.compare(value, other.value);
    }

    public java.lang.String toString() {
        return java.lang.Double.toString(value);
    }
    
    public static java.lang.String toString(double value) {
        return java.lang.Double.toString(value);
    }
    
    // Conversions between numeric types
    
    public long getInteger() {
        return getInteger(value);
    }
    
    
    public static long getInteger(double value) {
        if (value >= Long.MIN_VALUE && 
            value <= Long.MAX_VALUE) {
            return (long) value;
        }
        else {
            throw new OverflowException(value + 
                    " cannot be coerced to a 64 bit integer");
        }
    }
    
    
    public boolean getUndefined() {
        return Double.isNaN(this.value);
    }
    
    
    public static boolean getUndefined(double value) {
        return Double.isNaN(value);
    }
    
    
    public boolean getFinite() {
        return !Double.isInfinite(this.value) 
                && !getUndefined();
    }
    
    
    public static boolean getFinite(double value) {
        return !Double.isInfinite(value) 
                && !getUndefined(value);
    }
    
    
    public boolean getInfinite() {
        return Double.isInfinite(value);
    }
    
    
    public static boolean getInfinite(double value) {
        return Double.isInfinite(value);
    }
    
    
    public boolean equals(@Name("that") java.lang.Object that) {
        return equals(value, that);
    }
    
    
    public static boolean equals(double value, java.lang.Object that) {
        if (that instanceof Integer) {
            long intValue = ((Integer) that).value;
            return value == intValue 
                    && intValue > -Integer.TWO_FIFTY_THREE 
                    && intValue < Integer.TWO_FIFTY_THREE;
        } 
        else if (that instanceof Float) {
            return value == ((Float)that).value;
        } 
        else {
            return false;
        }
    }
    
    
    public int hashCode() {
        return hashCode(value);
    }
    
    
    public static int hashCode(double value) {
    	long wholePart = (long) value;
        if (value == wholePart) {// make integers and floats have consistent hashes
            return Integer.hashCode(wholePart);
        } else {
            final long bits = Double.doubleToLongBits(value);
            return (int)(bits ^ (bits >>> 32));
        }
    }

    
    
    public TypeDescriptor $getType$() {
        return $TypeDescriptor$;
    }

    
    public static boolean largerThan(double value, Float other) {
    	return value>other.value;
    }

    
    public static boolean largerThan(double value, double other) {
        return value>other;
    }
    
    
    public boolean largerThan(@Name("other")Float other) {
    	return value>other.value;
    }

    
    public static boolean notSmallerThan(double value, Float other) {
    	return value>=other.value;
    }

    
    public static boolean notSmallerThan(double value, double other) {
        return value>=other;
    }

    
    public boolean notSmallerThan(@Name("other") Float other) {
    	return value>=other.value;
    }

    
    public static boolean smallerThan(double value, Float other) {
    	return value<other.value;
    }

    
    public static boolean smallerThan(double value, double other) {
        return value<other;
    }

    
    public boolean smallerThan(@Name("other") Float other) {
    	return value<other.value;
    }

    
    public static boolean notLargerThan(double value, Float other) {
    	return value<=other.value;
    }

    
    public static boolean notLargerThan(double value, double other) {
        return value<=other;
    }

    
    public boolean notLargerThan(@Name("other") Float other) {
    	return value<=other.value;
    }
    
    
    public Float timesInteger(@Name("integer") long integer) {
    	return instance(value*integer);
    }
    
    
    public static double timesInteger(double value, long integer) {
    	return value*integer;
    }
    
    
    public Float plusInteger(@Name("integer") long integer) {
    	return instance(value+integer);
    }
    
    
    public static double plusInteger(double value, long integer) {
    	return value+integer;
    }
    
    
    public Float powerOfInteger(@Name("integer") long integer) {
        return instance(powerOfInteger(value,integer));
    }
    
    
    public static double powerOfInteger(double value, long integer) {
        if (integer == 0 && 
                !Double.isNaN(value)) {
            return 1.0;
        }
        else if (integer == 1) {
            return value;
        }
        else if (integer == 2) {
            return value*value;
        }
        else if (integer == 3) {
            return value*value*value;
        }
        else if (integer == 4) {
            double sqr = value*value;
            return sqr*sqr;
        }
        else if (integer == 5) {
            double sqr = value*value;
            return sqr*sqr*value;
        }
        else if (integer == 6) {
            double sqr = value*value;
            return sqr*sqr*sqr;
        }
        //TODO: other positive integer powers for which
        //      multiplication is more efficient than pow()
        else if (integer == -1) {
            return 1/value;
        }
        else if (integer == -2) {
            return 1/value/value;
        }
        else if (integer == -3) {
            return 1/value/value/value;
        }
        else if (integer == -4) {
            double sqr = value*value;
            return 1/sqr/sqr;
        }
        else if (integer == -5) {
            double sqr = value*value;
            return 1/sqr/sqr/value;
        }
        else if (integer == -6) {
            double sqr = value*value;
            return 1/sqr/sqr/sqr;
        }
        else {
            //NOTE: this function is _really_ slow!
            return Math.pow(value,integer);
        }
    }
    
    
    public static Float valueOf(java.lang.String string) {
        return instance(java.lang.Double.parseDouble(string));
    }
    
}

