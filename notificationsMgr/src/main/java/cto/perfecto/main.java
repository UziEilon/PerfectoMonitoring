package cto.perfecto;


public class main {

    public static void main(String[] args) {

        String phoneNumber=null;
        String jobName=null;

        try {


            phoneNumber = args[0];
            jobName = args[1];


        }catch (ArrayIndexOutOfBoundsException e)
        {
            System.out.println("Missing job name and number");

        }
       notificationUtils.sendSMS(" JOB "+jobName + " Ended with Errors",phoneNumber);

    }
}
