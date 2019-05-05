// MousePort
// Copyright (C) 2019 iPAWiND - All Rights Reserved
// https://github.com/ipawind/mouseport

import java.awt.*;
import java.awt.event.*;

import javax.swing.JFrame;
import javax.swing.*;
import java.net.InetAddress;

import org.json.simple.JSONObject;

public class MainView extends JFrame implements MouseListener, MouseMotionListener, WindowListener  {

    private UDPClient udpClient;

    private JSONObject obj = new JSONObject();

    private Point lastPoint;

    private JPanel panel1;
    private JLabel statusLabel;
    private boolean connected = false;

    private enum Event {

        moved(0), leftDown(1), leftUp(2), leftDragged(3);

        private int value;
        private Event(int value){
            this.value=value;
        }
    }

    public MainView() {

        setContentPane(panel1);

        // Full screen
        setExtendedState(JFrame.MAXIMIZED_BOTH);
        setUndecorated(true);
        setVisible(true);

        initiateConnection();

        // Listeners
        addMouseListener(this);
        addMouseMotionListener(this);
        addWindowListener(this);
    }

    private void initiateConnection() {

        System.out.println("initiateConnection");

        String scheme = "192.168.1.";
        String myIp = "";

        try {

            InetAddress inetAddress = InetAddress.getLocalHost();

            myIp = inetAddress.getHostAddress();

            String[] components = myIp.split("\\.");

            components[components.length-1] = "";

            scheme = String.join(".", components);

            System.out.println("IP Address:- " + scheme);

        } catch (Exception e) {
            System.out.println(e.getMessage());
        }

        for (int i = 0; i < 256; i++) {

            final int ipIndex = i;

            String ip = scheme + ipIndex;

            if (ip.equals(myIp)) continue;

            Runnable runnable = new Runnable() {
                @Override
                public void run() {

                    try {

                        UDPClient client = new UDPClient( ip, 1011);

                        if (client.test() == false || connected) return;

                        connected = true;

                        udpClient = client;

                        monitorConnection();

                        System.out.println("Test succeeded");

                        updateView();

                    } catch (Exception e) {
                        System.out.println(e.getMessage());
                    }
                }
            };

            Thread thread = new Thread(runnable);

            thread.start();
        }

        new Thread(new Runnable() {
            @Override
            public void run() {

                try {

                    Thread.sleep(3000);

                    if (connected == false) {
                        initiateConnection();
                    }

                } catch (Exception e) {

                }
            }
        }).start();

    }

    private void monitorConnection() {

        Runnable runnable = new Runnable() {
            @Override
            public void run() {

                // If server still responding keep pinging each 5 seconds
                if (udpClient.test()) {

                    try {

                        Thread.sleep(5000);

                        run();

                    } catch (Exception e) {

                    }

                }
                else {

                    // Server not responding, initiate the connection again.
                    connected = false;
                    initiateConnection();
                    updateView();
                }
            }
        };

        Thread thread = new Thread(runnable);

        thread.start();
    }

    private void updateView() {

        if (connected) {
            statusLabel.setText("CONNECTED");
            statusLabel.setForeground(hex2Rgb("#81c784"));
        }
        else {
            statusLabel.setText("Searching");
            statusLabel.setForeground(Color.black);
        }

    }

    public static void main(String args[])
    {
        Main application = new Main();
    }

    @Override
    public void mouseClicked(MouseEvent arg0) {
    }

    @Override
    public void mouseEntered(MouseEvent arg0) {

    }

    @Override
    public void mouseExited(MouseEvent arg0) {

    }

    @Override
    public void mousePressed(MouseEvent arg0) {
        sendMouseEvent(Event.leftDown);
    }

    @Override
    public void mouseReleased(MouseEvent arg0) {
        sendMouseEvent(Event.leftUp);
    }

    public void mouseMoved(MouseEvent e) {
        sendMouseEvent(Event.moved);
    }

    public void mouseDragged(MouseEvent e) {
        sendMouseEvent(Event.leftDragged);
    }

    public void sendMouseEvent(Event event) {

        Point p = MouseInfo.getPointerInfo().getLocation();

        System.out.println("x: "+p.x+" y: "+p.y);

        if (lastPoint == null) {
            lastPoint = p;
        }

        obj.put("event", event.value);
        obj.put("x", p.x - lastPoint.x);
        obj.put("y", p.y - lastPoint.y);

        lastPoint = p;

        try {
            this.udpClient.sendEcho(obj.toJSONString());
        } catch (Exception ex) {
            System.out.println(ex.getMessage());
        }
    }

    public static Color hex2Rgb(String colorStr) {
        return new Color(
                Integer.valueOf( colorStr.substring( 1, 3 ), 16 ),
                Integer.valueOf( colorStr.substring( 3, 5 ), 16 ),
                Integer.valueOf( colorStr.substring( 5, 7 ), 16 ) );
    }


    @Override
    public void windowOpened(WindowEvent windowEvent) {

    }

    @Override
    public void windowClosing(WindowEvent windowEvent) {
        System.exit(0);
    }

    @Override
    public void windowClosed(WindowEvent windowEvent) {

    }

    @Override
    public void windowIconified(WindowEvent windowEvent) {

    }

    @Override
    public void windowDeiconified(WindowEvent windowEvent) {

    }

    @Override
    public void windowActivated(WindowEvent windowEvent) {

    }

    @Override
    public void windowDeactivated(WindowEvent windowEvent) {

    }
}
