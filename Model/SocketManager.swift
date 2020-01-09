//
//  SocketManager.swift
//  BonjourDev
//
//  Created by Mark Duek on 27/09/18.
//  Copyright © 2018 Mark Duek. All rights reserved.
//

import Foundation
import Socket

/// This Class manages socket information.
class SocketManager {
    //MARK: - Properties
    
    ///SocketManager singleton
    static let shared: SocketManager = SocketManager()
    
    var server: Server!
    var client: Client!
    
    ///Verifies if server is on.
    var isServer: Bool = false
    ///Verify if someone is connected to the server.
    var isConnected: Bool = false
    
    var bonjourDict : [String:String]!
    
    var colorToChange: String!
}

//MARK: - SocketManager extension for the server

extension SocketManager: ServerDelegate {
    
    //MARK: Server Methods
    /**
     Initizlizes Server.
     - Parameters:
        - name: Server name String.
     */
    func setUpServer(name: String) {
        server = Server()
        server.delegate = self
        self.isServer = true
        server.createService(lobbyName: name)
    }
    
    /**
     Function called when server is created.
     */
    func didCreateServer() {debugPrint(#function)
        let ip = Bonjour.shared.getWiFiAddress()
        let port = server.port
        debugPrint("Server: Tried to connect with Ip: \(ip!)")
        debugPrint("Server: Tried to connect to Port: \(String(describing: port))")
    }
    
    /**
        Function called when someone connects to server.
     */
    func didConnectWithServer() {debugPrint(#function)
        isConnected = true
    }
    
    /**
     Writes a Dictionary in every Client connected.
     - Parameters:
        - dataDict: Dictinonary that will be written.
     */
    func writeInSocket(dataDict: [String:Any]) {
        SocketManager.shared.server.clientSockets.forEach ({
            (socket) in
            do {
                let data = try JSONSerialization.data(withJSONObject: dataDict, options: [])
                debugPrint("Transformed dictionary in data")
                do {
                    try socket.write(from: data)
                    debugPrint("Wrote on socket ==> \(dataDict)")
                } catch let (error) {
                    debugPrint(error)
                    debugPrint("Couldn't write in socket")
                }
            } catch let error {
                debugPrint(error)
                debugPrint("Error in conversion of dictionary to Data")
            }
        })
    }
    /**
     Verifies and resolves Dictionary information that the server recieved.
     - Parameters:
        -  receivedDict: Dictionary recieved to be treated.
     */
    func didReceiveServerInfo(receivedDict: [String:Any]) { debugPrint(#function)
        if let infoReceived = receivedDict["isConnected"] {
            if infoReceived as! String == "true"{
                SocketManager.shared.isConnected = true
            }
        }
        if let color = receivedDict["color"] {
            if color as! String == "change"{
                SocketManager.shared.colorToChange = "yes"
            }
        }
    }
    
    //MARK: Decoders
    
    func decodeTxtRecord(toDictionary recordData: Data) -> [String:String] {
        
        let decodedData: [String:Data] = NetService.dictionary(fromTXTRecord: recordData)
        
        var decodedDictionary: [String:String] = [:]
        let keys = ["Name", "State", "Creator", "Ip", "Port"]
        
        for key in keys {
            decodedDictionary[key] = opDataToString(decodedData[key])
        }
        return decodedDictionary
    }
    
    /// Transforms Data into String. Auxiliar function to decodeTxtRecord.
    func opDataToString(_ data:Data?)->String {
        if let decoded = data {
            return String(data:  decoded, encoding: String.Encoding.utf8) ?? ""
        }
        return ""
    }
    
    func decodeDictionary(toData dictionaryTxt: [String:String]) -> Data {
        debugPrint(dictionaryTxt)
        let jsonObject: [String: Data] = [
            "State": (dictionaryTxt["State"]?.data(using: .utf8))!,
            "Ip" : (dictionaryTxt["Ip"]?.data(using: .utf8))!,
            "Port" : (dictionaryTxt["Port"]?.data(using: .utf8))!
        ]
        
        let data = NetService.data(fromTXTRecord: jsonObject)
        
        return data
    }
}

//MARK: - SocketManager extension for the Client

extension SocketManager: ClientDelegate {
    
    //MARK: Client Methods
    
    /**
     Initizlizes Client.
     - Version: 1.0 X Animes Edition
     */
    func setUpClient() {
        client = Client()
        client.delegate = self
        client.searchForServerClient()
    }
    /**
     Verifies that the Client recived data from the Server.
     - Parameters: Dicionario recebeido pela função para ser tratado
     */
    func didReceiveClientInfo(receivedDict: [String:Any]) {debugPrint(#function)
        debugPrint("Client: Recived information")
        debugPrint("DICTIONARY =>>" , receivedDict)
    }
    /**
     Called when a service is found.
     */
    func serviceFound(service: NetService) {debugPrint(#function)
        debugPrint(service.name)
        service.resolve(withTimeout: 10)
    }
    
    ///After the sevice has been found, puts Bonjour's information on bonjourDict, allowing Clients to connect  to the Server that published its information.
    func didResolveService(resolvedNetService: NetService) {
        debugPrint(#function)
        debugPrint(resolvedNetService.txtRecordData() as Any)
        let txtRecord = resolvedNetService.txtRecordData()!
        debugPrint(txtRecord)
        
        bonjourDict = SocketManager.shared.decodeTxtRecord(toDictionary: txtRecord)
        debugPrint(bonjourDict)
        resolvedNetService.startMonitoring()
        let port = Int(bonjourDict["Port"]!)
        client.connect(ip: bonjourDict["Ip"]!, port: port!)
    }
    
    //MARK: - Client Delegate
    func didNotResolveService(netService: NetService) {debugPrint(#function)}
    
    func didUpdateTxtRecord(newData: Data) {debugPrint(#function)}
    
    func didLostService(netService: NetService) {debugPrint(#function)}
    
}













