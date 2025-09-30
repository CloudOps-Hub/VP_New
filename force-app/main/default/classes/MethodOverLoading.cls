public class MethodOverLoading {
    //data memebers
    Integer num1, num2, num3, num4, result;
    //member methods
    //1.create
    public MethodOverLoading(){
    	num1=0;
    	num2=0;
    	num3=0;
    	num4=0;
    	result=0;
    }
    //2.input
    public void setValues(integer a,integer b){
        num1 = a;
        num2 = b;
    }
        public void setValues(integer a,integer b, integer c){
        num1 = a;
        num2 = b;
        num3 = c;
    }
     public void setValues(integer a,integer b, integer c,integer d){
        num1 = a;
        num2 = b;
        num3 = c;
        num4 = d;
     }
    //3.process
    public Integer addition(){
        result = num1+num2;
        return result;
    }
    public Integer substraction (){
        result = num1-num2-num3;
        return result;
    }
    public Integer multiplication(){
        result = num1*num2*num3*num4;
        return result;
        }
}