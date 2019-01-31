package cto.perfecto;


import com.twilio.Twilio;
import com.twilio.rest.api.v2010.account.Message;

public class notificationUtils {

    static final String ACCOUNT_SID = "[Twilio account ID]";
    static final String AUTH_TOKEN = "[ Twilio AUTH_TOKEN] ";


    public static void sendSMS(String msg ,String phoneNumber) {
        Twilio.init(ACCOUNT_SID, AUTH_TOKEN);
        Message message = Message.creator(
                new com.twilio.type.PhoneNumber(phoneNumber),
                new com.twilio.type.PhoneNumber("+19785226401"),
                msg
        )
                .create();

        System.out.println(message.getSid());
    }

}
