//
//  Server.swift
//  BonjourDev
//
//  Created by Mark Duek on 27/09/18.
//  Copyright © 2018 Mark Duek. All rights reserved.
//

import Foundation
import Socket

class Server: NSObject, NetServiceDelegate {
    
    var delegate: ServerDelegate?
    
    // MARK: - BONJOUR VARIABLES -
    
    var serviceServer: NetService!
    
    // MARK: - SOCKET VARIABLES -
    
    var socket: Socket!
    var clientSockets: [Socket] = []
    var serverIsRunning = true
    
    static let bufferSize = 409600
    
    // ToDo: Pegar porta aleatoria
    var port: Int!
    
    deinit {
        socket = nil
        clientSockets = []
        serverIsRunning = true
    }
    /// Create a bonjour Service
    ///
    /// - Parameter lobbyName: Name of the lobby
    func createService(lobbyName: String){
        
        // TODO: create a random port
        serviceServer = NetService(domain: "", type: "_testeDevPlusUltra._tcp", name: lobbyName, port: 2023)
        
        port = serviceServer.port
        print(port)
        runServer(port: port)
        
        if let serviceServer = serviceServer {
            
            serviceServer.delegate = self
            serviceServer.publish()
            Bonjour.shared.didPublishBonjour(netService: serviceServer)
        }
    }
    // MARK: - SOCKET METHODS -
    //
    // ===================== SOCKET METHODS ================================
    //
    
    /// Creates a socket and a Thread to listen the port for new clients to connect. Calling the function addNewConnection when found
    ///
    /// - Parameter port: The port in which the server will listen
    func runServer(port: Int){
        
        self.port = port
        
        do {
            // Create an IPV6 socket
            try self.socket = Socket.create(family: .inet)
            
        } catch let error {
            print (error)
            print("Can`t create socket")
            return
        }
        
        // abrindo porta para conexão
        do {
            try self.socket.listen(on: self.port)
            print("Listening on port: \(self.socket.listeningPort)")
        } catch let error {
            print(error)
            print("Can`t listen on port: \(self.port)")
            return
        }
        
        // Thread to find new clients trying to connect
        let queue = DispatchQueue(label: "Listening clients thread", qos: .utility)
        queue.async {
            
            self.delegate?.didCreateServer()
            
            repeat {
                
                do {
                    let clientSocket = try self.socket.acceptClientConnection()
                    print("Accepted new client")
                    print("New client is: \(clientSocket.remoteHostname)")
                    self.addNewConnection(clientSocket: clientSocket)

                } catch let error {
                    print(error)
                    print("Can`t accept new client")
                }
            } while self.serverIsRunning
        }
    }
    
    func addNewConnection(clientSocket: Socket) {
        
        // Adding the new client to the array
        self.clientSockets.append(clientSocket)
        
        // Creating thread to listen to the new client
        let queue = DispatchQueue(label: "Listening for client \(clientSocket.remoteHostname))", qos: .background)
        
        queue.async {
            
            var readData = Data(capacity: Server.bufferSize)
            var isRunning = true
            
            repeat {
                
                // If socket has been disconnected the thread must stop
                if !clientSocket.isConnected {
                    print("Disconnected")
                    
                    isRunning = false
                    return
                }
                
                do {
                    let bytesRead = try clientSocket.read(into: &readData)
                    
                    print("\n\n\nSERVER WILL SEND \(readData)\n\n\n")
                    // If there was a new message to be read
                    if bytesRead > 0 {
                        
                        do {
                            // Decoding Data to Json
                            let decoded = try JSONSerialization.jsonObject(with: readData, options: []) as! [String : Any]
                            
                            self.delegate?.didReceiveServerInfo(receivedDict: decoded)
                            
                            readData.count = 0
                            
                        } catch let error {
                            print(error)
                            print("Something went wrong when decoding data")
                        }
                    }
                } catch let error {
                    print(error)
                    print("Server were unable to read \(clientSocket.remoteHostname)")
                    return
                }
                
            } while isRunning
        }
        
    }
    
    // MARK: - OTHER METHODS -
    //
    // ===================== OTHER METHODS ================================
    //
    
    
    /// Function responsable to pass the IP address of the device
    ///
    /// - Returns: IP address of the connected wifi as a String or 'nil'
    func getWiFiAddress() -> String? {
        var address : String?
        
        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return nil }
        guard let firstAddr = ifaddr else { return nil }
        
        // For each interface ...
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee
            
            // Check for IPv4 or IPv6 interface:
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                
                // Check interface name:
                let name = String(cString: interface.ifa_name)
                if  name == "en0" {
                    
                    // Convert interface address to a human readable string:
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostname, socklen_t(hostname.count),
                                nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostname)
                }
            }
        }
        freeifaddrs(ifaddr)
        
        return address
    }
    
    /// Close one of the sockets
    ///
    /// - Parameters:
    ///   - socket: the socket that must be closed
    ///   - index: index of the socket that must be closed
    func closeIndividualSocket(_ socket: Socket, index: Int) {
        clientSockets.remove(at: index)
        socket.close()
    }
    
    
    /// Close all sockets connected to the socket removes all sockets from the array of sockets and close the server Scoket
    func closeServerSockets(){
        
        debugPrint(#function)
        serverIsRunning = false
        clientSockets.forEach { (clientSocket) in
            clientSocket.close()
        }
        clientSockets.removeAll()
        socket.close()
    }

}

protocol ServerDelegate {
    
    /// Called every time the server receives a message. It already makes the decoding to a dictionary of [String:Any]
    ///
    /// - Parameter receivedDict: Data received already decoded
    func didReceiveServerInfo(receivedDict: [String:Any])
    
    /// Called when the bonjour has been published
    func didPublishBonjour(netService: NetService)
    
    func didCreateServer()
}

// Did find new client
//
//
//

extension ServerDelegate {
    
    func didReceiveServerInfo(receivedDict: [String:Any]) {}
    
    func didPublishBonjour(netService: NetService) {}
    
    func didCreateServer() {}
}
