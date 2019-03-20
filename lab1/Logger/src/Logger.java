import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;
import java.net.DatagramPacket;
import java.net.InetAddress;
import java.net.MulticastSocket;
import java.nio.charset.StandardCharsets;
import java.sql.Timestamp;


public class Logger {
    public static BufferedWriter writer;

    public static void main(String[] args) throws IOException {
        MulticastSocket multicastSocket;
        writer = new BufferedWriter(new FileWriter("/home/krzysztof/Studia/Rozprochy/lab1/log.txt"));
        InetAddress group = InetAddress.getByName("230.1.1.1");
        multicastSocket = new MulticastSocket(12345);
        multicastSocket.joinGroup(group);
        ShutDownTask shutDownTask = new ShutDownTask();
        Runtime.getRuntime().addShutdownHook(shutDownTask);

        while (true) {
            byte[] buf = new byte[15];
            DatagramPacket recv = new DatagramPacket(buf, buf.length);
            multicastSocket.receive(recv);
            String msg = new String(recv.getData(), StandardCharsets.UTF_8);
            System.out.println(new Timestamp(System.currentTimeMillis()) + ": " + msg);
            writer.write(new Timestamp(System.currentTimeMillis()) + ": " + msg + "\n");
        }
    }

    private static class ShutDownTask extends Thread {
        @Override
        public void run() {
            System.out.println("Shutting down");
            try {
                writer.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }
}