import org.jgroups.*;
import org.jgroups.protocols.*;
import org.jgroups.protocols.pbcast.*;
import org.jgroups.stack.ProtocolStack;
import java.net.InetAddress;
import java.util.Scanner;

public class Client {

    private DistributedMap distributedMap;
    private Scanner scanner = new Scanner(System.in);
    JChannel channel;
    public Client() {
    }

    public void start() throws Exception {

        channel = new JChannel(false);
        setProtocols();
        channel.connect("distributedMap");
        distributedMap=new DistributedMap(channel);
        while(true){
            System.out.println("Write <operation> <argument> [second arg for put], types: containsKey -> 1, get -> 2, put -> 3, remove -> 4");
            String text=scanner.nextLine();
            String[] arguments = text.split(" ");
            try {
                switch (arguments[0]) {
                    case "1":
                        validate_2_args(arguments);
                        System.out.println(distributedMap.containsKey(arguments[1]));
                        break;
                    case "2":
                        validate_2_args(arguments);
                        System.out.println(distributedMap.get(arguments[1]));
                        break;
                    case "3":
                        validate_3_args(arguments);
                        System.out.println(distributedMap.put(arguments[1], arguments[2]));
                        break;
                    case "4":
                        validate_2_args(arguments);
                        System.out.println(distributedMap.remove(arguments[1]));
                        break;
                }
            }
            catch (IllegalArgumentException e){
                System.out.println(e.getMessage());
            }
        }
    }

    private void setProtocols() throws Exception {
        ProtocolStack stack = new ProtocolStack();
        channel.setProtocolStack(stack);
        stack.addProtocol(new UDP().setValue("mcast_group_addr", InetAddress.getByName("230.100.200.54")))
                .addProtocol(new PING())
                .addProtocol(new MERGE3())
                .addProtocol(new FD_SOCK())
                .addProtocol(new FD_ALL().setValue("timeout", 12000).setValue("interval", 3000))
                .addProtocol(new VERIFY_SUSPECT())
                .addProtocol(new BARRIER())
                .addProtocol(new NAKACK2())
                .addProtocol(new UNICAST3())
                .addProtocol(new STABLE())
                .addProtocol(new GMS())
                .addProtocol(new UFC())
                .addProtocol(new MFC())
                .addProtocol(new FRAG2())
                .addProtocol(new STATE_TRANSFER());
        stack.init();
    }


    public void validate_3_args(String[] arguments){
        if(arguments.length!=3) {
            throw new IllegalArgumentException("This method needs 3 arguments");
        }
    }

    public void validate_2_args(String[] arguments){
        if(arguments.length!=2) {
            throw new IllegalArgumentException("This method needs 2 arguments");
        }
    }
}


