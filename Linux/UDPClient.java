import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.InetAddress;

public class UDPClient {

        private DatagramSocket socket;
        private InetAddress address;

        private byte[] buf;
        private int port;

        public UDPClient(String serverIp, int port) throws Exception {

            socket = new DatagramSocket();

            address = InetAddress.getByName(serverIp);

            this.port = port;
        }

        public boolean test() {

            buf = "ping".getBytes();

            DatagramPacket packet = new DatagramPacket(buf, buf.length, address, this.port);

            try {

                socket.send(packet);

                packet = new DatagramPacket(buf, buf.length);

                socket.setSoTimeout(1000);

                socket.receive(packet);

                String received = new String(packet.getData(), 0, packet.getLength());

                System.out.println("Received "+received);

                return received.equals("ping");

            } catch (Exception e) {

            }

            return false;
        }

        public String sendEcho(String msg) throws Exception {

            buf = msg.getBytes();

            DatagramPacket packet = new DatagramPacket(buf, buf.length, address, 1011);

            socket.send(packet);

            return null;
        }

        public void close() {
            socket.close();
        }
}
