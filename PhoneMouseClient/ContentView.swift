//
//  ContentView.swift
//  PhoneMouseClient
//
//  Created by Mike Bugden on 1/14/25.
//

import Foundation
import SwiftUI
import SignalRClient

struct CustomKeyboard: View {
    @Binding var connection: HubConnection?
    @Binding var isDarkMode: Bool
    @Binding var isIPConfiguratorOpen: Bool
    @Binding var hostPCipv4: String
    @State private var isShiftActive: Bool = false  // Track Shift state
    @State private var isNumericLayoutActive: Bool = false
    @State private var isSpclCharActive: Bool = false
    
    
    // Define the layout for the keys (rows for numbers and letters)
    let keysUpper = [
        ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"],
        ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"],
        ["A", "S", "D", "F", "G", "H", "J", "K", "L"],
        ["⇧", "Z", "X", "C", "V", "B", "N", "M", "⌫"]
    ]
    
    let keysLower = [
        ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"],
        ["q", "w", "e", "r", "t", "y", "u", "i", "o", "p"],
        ["a", "s", "d", "f", "g", "h", "j", "k", "l"],
        ["⇧", "z", "x", "c", "v", "b", "n", "m", "⌫"]
    ]
    
    let keysSpecial = [
        ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"],
        ["~", "@", "#", "$", "%", "^", "&", "*", "(", ")"],
        ["-", "_", "=", "+", "{", "}", "[", "]", "|", "\\"],
        ["/", ":", ";", "<", ">", ".", ",", "?", "!", "`"]
    ]
    // Handle button tap action
    func handleButtonTap(_ key: String) {
        if (isIPConfiguratorOpen) {
            //if key is number or '.'
            if (key != "123" && "0123456789.".contains(key)) {
                hostPCipv4 += key
            } else if (key == "⌫") {
                if(hostPCipv4.count > 0) {
                    hostPCipv4.removeLast()
                }
            }
            return
        }
        
        var sendKey: String = key
        var shouldSend: Bool = true
        if key == "⌫" {
            sendKey = "BACK"
        } else if key == "→" {
            sendKey = "ENTER"
        } else if key == "⇧" {
            isShiftActive.toggle()
            shouldSend = false
        } else if key == "123" {
            isSpclCharActive.toggle()
            shouldSend = false
        }
        
        if (shouldSend) {
            self.connection?.invoke(method: "SendKey", arguments: [sendKey]) { result in
                print("Request Sent!")
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 5) {
            // Create the keyboard layout
            ForEach(isSpclCharActive ? keysSpecial : (isShiftActive ? keysUpper : keysLower), id: \.self) { row in
                HStack(spacing: 2) {
                    ForEach(row, id: \.self) { key in
                        if key.isEmpty {
                            Spacer() // Empty space for padding
                        } else if (key == "⌫") {
                            Button(action: {
                                handleButtonTap(key)
                            }) {
                                Text(key)
                                    .font(.title)
                                    .frame(width: 50, height: 40)
                                    .background(Color.red)
                                    .cornerRadius(10)
                                    .foregroundColor(.white)
                            }
                        } else if (key == "⇧") {
                            Button(action: {
                                handleButtonTap(key)
                            }) {
                                Text(key)
                                    .font(.title)
                                    .frame(width: 50, height: 40)
                                    .background(Color.blue)
                                    .cornerRadius(10)
                                    .foregroundColor(.white)
                            }
                        } else {
                            Button(action: {
                                handleButtonTap(key)
                            }) {
                                Text(key)
                                    .font(.title)
                                    .frame(width: 37, height: 45)
                                    .background(self.isDarkMode ? Color.gray.opacity(0.7) : Color.gray.opacity(0.3))
                                    .cornerRadius(10)
                                    .foregroundColor(self.isDarkMode ? .white : .black)
                            }
                        }
                    }
                }
            }
            
            // Add both "Space", "Backspace" and "Shift" buttons on the same row
            HStack(spacing: 5) {
//                Button(action: {
//                    handleButtonTap("Shift")
//                }) {
//                    Text("Shift")
//                        .font(.title)
//                        .frame(width: 100, height: 50)
//                        .background(Color.blue)
//                        .cornerRadius(10)
//                        .foregroundColor(.white)
//                }
                Button(action: {
                    handleButtonTap("123")
                }) {
                    Text(isSpclCharActive ? "abc" : "123")
                        .font(.title)
                        .frame(width: 50, height: 50)
                        .background(self.isDarkMode ? Color.gray.opacity(0.7) : Color.gray.opacity(0.3))
                        .cornerRadius(10)
                        .foregroundColor(self.isDarkMode ? .white : .black)
                }
                Button(action: {
                    handleButtonTap("Space")
                }) {
                    Text("Space")
                        .font(.title)
                        .frame(width: 250, height: 50)
                        .background(self.isDarkMode ? Color.gray.opacity(0.7) : Color.gray.opacity(0.3))
                        .cornerRadius(10)
                        .foregroundColor(self.isDarkMode ? .white : .black)
                }
                Button(action: {
                    handleButtonTap(".")
                }) {
                    Text(".")
                        .font(.title)
                        .frame(width: 25, height: 50)
                        .background(self.isDarkMode ? Color.gray.opacity(0.7) : Color.gray.opacity(0.3))
                        .cornerRadius(10)
                        .foregroundColor(self.isDarkMode ? .white : .black)
                }
                Button(action: {
                    handleButtonTap("→")
                }) {
                    Text("→")
                        .font(.title)
                        .frame(width: 35, height: 50)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .foregroundColor(.white)
                }
            }
        }
        .padding()
    }
}

struct mousePad: View {
    @Binding var connection: HubConnection?
    @Binding var mouseSens: Double
    
    var body : some View {
        Rectangle()
            .frame(width: 370, height: 300)
            .foregroundColor(.gray)
            .highPriorityGesture(DragGesture()
                .onChanged { value in
                    moveMouse(
                        deltaX: Double(value.translation.width) * mouseSens,
                        deltaY: Double(value.translation.height) * mouseSens)
                }
                .onEnded { value in
                    self.connection?.invoke(method: "MouseMoveFinished", arguments: []) { result in
                        print("MouseMoveFinishedReqSent")
                    }
                    print("drag ended")
                }
            )
            .simultaneousGesture(TapGesture()
                .onEnded {
                    print("Rectangle tapped")
                    // Add your tap gesture logic here
                    self.connection?.invoke(method: "MouseClick", arguments: ["M1"]) { result in
                            print("Tap gesture sent to server")
                    }
                }
            )
            .cornerRadius(20)
            .padding()
    }
    
    func moveMouse(deltaX: Double, deltaY: Double) {
        print("Mouse moved: (\(deltaX), \(deltaY))")
        self.connection?.invoke(method: "MoveMouse", arguments: [deltaX, deltaY]) { result in
            print("Request Sent!")
        }
    }
    
}

struct ContentView: View {
    @State private var connection: HubConnection? = nil
    @State private var statusMessage: String = "Disconnected"
    @State private var input: String = ""
    
    @FocusState private var isKeyboardVisible: Bool
    @State private var inputText: String = ""
    
    @State private var isHolding = false
    
    @State private var heartbeatTimer: Timer? = nil
    
    @State private var isDarkMode: Bool = false // Toggle state
    //@State private var localIPAddress: String = "0.0.0.0" // Default IP address
    @State private var mouseSensitivity: Double = 2.0 // Default sensitivity
    
    @State private var showIPConfigurator: Bool = false
    @State private var hostPCipv4: String = "0.0.0.0"
    @State private var hostIP: String = ":5123/controlHub"
    @FocusState private var isIPFieldFocused: Bool

    
    private var darkModeBackgroundColor = Color.black.opacity(0.9)
    private var backgroundColor = Color.white
    
    
    var body: some View {
        VStack (spacing: 0) {
            HStack {
                Button(action: {
                    (statusMessage == "Disconnected" || statusMessage == "Connecting...") ? connectToSignalR() : disconnectSignalR()
                }) {
                    Text((statusMessage == "Disconnected" || statusMessage == "Connecting...") ? "Connect" : "Disconnect")
                        .font(.system(size: 20))
                        .frame(width: 110, height: 25)
                        .background(Color.gray.opacity(0.0))
                        .cornerRadius(10)
                        .foregroundColor(.blue)
                }
                .padding()
                Text(statusMessage)
                    .bold()
                    .font(.system(size: 20))
                    .frame(width: 150, height: 25)
                    .foregroundColor((statusMessage == "Disconnected") ? .red : ((statusMessage == "Connecting...") ? .yellow : .green))
                    .padding()
                Menu {
                    // Dark Mode Toggle
                    Toggle("Dark Mode", isOn: $isDarkMode)
                        .onChange(of: isDarkMode) { newValue in
                            print("Dark Mode is now \(newValue ? "Enabled" : "Disabled")")
                        }
                    
                    // Local IP Address Input
//                    Section(header: Text("Network")) {
//                            TextField("Enter IP Address", text: $localIPAddress)
//                                .textFieldStyle(RoundedBorderTextFieldStyle()) // Adds some basic styling
//                                .keyboardType(.numberPad)
//                                .frame(width: 150, height: 20) // Ensure it has enough width
//                                .focused($isIPFieldFocused) // Focus the text field when tapped
//                                .onSubmit {
//                                    print("New IP Address: \(localIPAddress)")
//                                }
//                                .background(Color.gray.opacity(0.1)) // Add a background for visual feedback
//                                .cornerRadius(8)
//                    }
                    Toggle("Configure Host IP", isOn: $showIPConfigurator)
                        .onChange(of: showIPConfigurator) { newValue in
                            print("IP is now \(newValue)")
                        }
                    // Mouse Sensitivity Slider
                    Section(header: Text("Mouse Settings")) {
                        VStack(alignment: .leading) {
//                            Text("Mouse Sensitivity: \(String(format: "%.1f", mouseSensitivity))")
                            Slider(value: $mouseSensitivity, in: 0.5...5.0, step: 0.1) {
                                Text("Mouse Sensitivity :  \(String(format: "%.1f", mouseSensitivity))")
                            }
                            .onChange(of: mouseSensitivity) { newValue in
                                print("Mouse sensitivity adjusted to \(newValue)")
                            }
                        }
                    }
                    
                    // Reset Preferences
                    Button("Reset Preferences", role: .destructive) {
                        isDarkMode = false
                        hostPCipv4 = "0.0.0.0"
                        mouseSensitivity = 1.0
                        print("Preferences reset to defaults")
                    }
                } label: {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.blue)
                        .background(isDarkMode ? self.darkModeBackgroundColor : self.backgroundColor)
                }
                //.frame(width: 350) // Set the width of the Menu to ensure enough space
                //.padding(20) // Add padding around the menu to increase space
                // Optional: background color for visibility
                .cornerRadius(15)
                
            }
            Text("Phone Mouse")
                .font(.title)
                .bold()
                .foregroundColor(isDarkMode ? self.backgroundColor : self.darkModeBackgroundColor)
                .frame(width: 360, height: 30)
                .cornerRadius(10)
            
            if (self.showIPConfigurator) {
                Text(hostPCipv4)
                    .frame(width: 350, height: 50)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numbersAndPunctuation) // For IP input
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .multilineTextAlignment(.center)
                    .onSubmit {
                        print("New IP Address: \(hostPCipv4)")
                    }
                    .onTapGesture {
                        isIPFieldFocused = true // Manually focus the text field
                    }
            } else {
                Spacer().frame(height: 50)
            }

            // You can add a touch area or other components to simulate mouse movement
            mousePad(connection: self.$connection, mouseSens: self.$mouseSensitivity)
            
            HStack {
                Button(action: {
                    endMousePress(mButton: "M2")
                }) {
                    Text("M2")
                        .font(.system(size: 20))
                        .frame(width: 180, height: 40)
                        .background(Color.gray)
                        .cornerRadius(10)
                        .foregroundColor(.black)
                }
                .simultaneousGesture(
                    LongPressGesture(minimumDuration: 0) // Adjust hold duration
                        .onChanged { _ in
                        }
                        .onEnded { _ in
                            startMousePress(mButton: "M2")
                        }
                )
                Button(action: {
                    endMousePress(mButton: "M1")
                }) {
                    Text("M1")
                        .font(.system(size: 20))
                        .frame(width: 180, height: 40)
                        .background(Color.gray)
                        .cornerRadius(10)
                        .foregroundColor(.black)
                }
                .simultaneousGesture(
                    LongPressGesture(minimumDuration: 0) // Adjust hold duration
                        .onChanged { _ in
                        }
                        .onEnded { _ in
                            //ONPRESS
                            startMousePress(mButton: "M1")
                        }
                )
            }
            
            CustomKeyboard(connection: self.$connection, isDarkMode: self.$isDarkMode, isIPConfiguratorOpen: self.$showIPConfigurator, hostPCipv4: self.$hostPCipv4)
        }
        .padding()
        .background(isDarkMode ? self.darkModeBackgroundColor : self.backgroundColor)
    }
    
    // Connect to SignalR Hub
    func connectToSignalR() {
        statusMessage = "Connecting..." // Set initial connection status
        self.hostIP = "http://\(self.hostPCipv4):5123/controlHub"
        self.connection = HubConnectionBuilder(url: URL(string: self.hostIP)!)
            .withLogging(minLogLevel: .debug)
            .build()
        
        self.connection!.on(method: "ClientConnected", callback: {(message: String) in
            print("recievedMessage \(message)")
            // Update the status message on the main thread
            if message == "Connected" {
                DispatchQueue.main.async {
                    statusMessage = "Connected"
                    self.heartbeatTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { timer in
                        // Task to perform every 10 seconds
                        checkHeartbeat()
                        print("Heartbeat checker sent")
                    }
                }
            }
            
        })
        
        self.connection!.start()
        
        // If connection isn't successful immediately, set the status to "Disconnected"
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            if self.statusMessage != "Connected" {
                self.statusMessage = "Disconnected"
            }
        }
    }
    
    func disconnectSignalR() {
        self.statusMessage = "Disconnected"
        self.connection = nil
        self.cancelHeartbeat()
    }
    
    func startMousePress(mButton: String) {
        self.connection?.invoke(method: "MousePress", arguments: [mButton]) { result in
            print("MouseDown Request Sent!")
        }
    }
    
    func endMousePress(mButton: String) {
        self.connection?.invoke(method: "MouseRelease", arguments: [mButton]) { result in
            print("MouseUp Request Sent!")
        }
    }
    
    func checkHeartbeat() {
        self.connection?.invoke(method: "Heartbeat", arguments: [], invocationDidComplete: { Error in
            if Error != nil {
                DispatchQueue.main.async {
                    self.statusMessage = "Disconnected"
                    self.connection = nil
                    self.cancelHeartbeat()
                }
                print("Heartbeat failed")
            } else {
                print("Heartbeat confirmed")
            }
        })
    }
    
    func cancelHeartbeat() {
        heartbeatTimer?.invalidate()
        heartbeatTimer = nil
    }
    
    // Send Command to SignalR Server
    func sendCommand(_ command: String) {
        self.connection?.invoke(method: "SendCommand", arguments: [command]) { result in
            print("Command sent: \(command)")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
