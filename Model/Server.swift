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
    
    
    
    // MARK: - SOCKET VARIABLES -
    var socket: Socket!
    var clientSockets: [Socket] = []
    var serverIsRunning = true
    var port: Int!
    static let bufferSize = 100000000
    
    
    // MARK: - BONJOUR VARIABLES -
    
    var serviceServer: NetService!
    
    
    
    
    
    // MARK: -  Server Delegate  -
    
    var delegate: ServerDelegate?
    
    
    
    
    
    

    
    
    
    
    
    
    
    
    
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
        debugPrint(port)
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
