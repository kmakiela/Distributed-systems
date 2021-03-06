import org.jgroups.*;
import org.jgroups.util.Util;
import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import static java.lang.System.*;


public class DistributedMap extends ReceiverAdapter implements SimpleStringMap {

    private Channel channel;
    private Map<String , String> hashMap = new ConcurrentHashMap<>();
    private MapHandler mapHandler;

    public DistributedMap(Channel ch) throws Exception {
        this.channel =ch;
        ch.setReceiver(this);
        ch.getState(null,10000);
    }

    @Override
    public boolean containsKey(String key) {
        return hashMap.containsKey(key);
    }

    @Override
    public String get(String key) {
        return hashMap.get(key);
    }

    @Override
    public String put(String key, String value) throws Exception {
        mapHandler=new MapHandler(key,value);
        sendMessage(mapHandler);
        return hashMap.put(key,value);
    }

    @Override
    public String remove(String key) throws Exception {
        mapHandler=new MapHandler(key);
        sendMessage(mapHandler);
        return hashMap.remove(key);
    }

    @Override
    public void getState(OutputStream output) throws Exception {
        synchronized(hashMap) {
            Util.objectToStream(hashMap, new DataOutputStream(output));
        }
    }

    @Override
    public void setState(InputStream input) throws Exception {
        Map<String, String> map;
        map = (ConcurrentHashMap<String, String>) Util.objectFromStream(new DataInputStream(input));
        synchronized (hashMap) {
            hashMap.clear();
            hashMap.putAll(map);
        }
        out.println(map.size() + " messages recorded");
    }


    public void receive(Message msg) {
        System.out.println(msg.getObject());
        update(msg.getObject());
    }


    private void update(Object message){
        String[] arguments=message.toString().split(" ");
        if(arguments[0].equals(new String("REMOVE"))){
            hashMap.remove(arguments[1]);
        }
        else {
            hashMap.put(arguments[1],arguments[2]);
        }

    }

    public void sendMessage(MapHandler mapHandler) throws Exception {
        Message msg = new Message(null, null, mapHandler);
        channel.send(msg);
    }

    @Override
    public void viewAccepted(View view) {
        if(view instanceof MergeView) {
            ViewHandler viewHandler = new ViewHandler((JChannel) channel, (MergeView) view);
            viewHandler.start();
        }
    }
}
