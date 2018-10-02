//
//  SocketManager.swift
//  BonjourDev
//
//  Created by Mark Duek on 27/09/18.
//  Copyright © 2018 Mark Duek. All rights reserved.
//

import Foundation
import Socket

class SocketManager {
    
    static let shared: SocketManager = SocketManager()
    
    var server: Server!
    var client: Client!
    var isServer: Bool = false
    var isConnected: Bool = false
    var bonjourDict : [String:String]!
    
    var colorToChange: String!
}
extension SocketManager: ServerDelegate {
    
    func setUpServer(name: String) {
        server = Server()
        server.delegate = self
        self.isServer = true
        server.createService(lobbyName: name)
    }
    
    
    
    
    func didCreateServer() {debugPrint(#function)
        let ip = Bonjour.shared.getWiFiAddress()
        let port = server.port
        print("tries to connect in Ip: \(ip!)")
        print("tries to connect in Port: \(port)")
    }
    func didConnectWithServer() {debugPrint(#function)
        isConnected = true
    }

    
    
    
    //////// Escreve NO socket //////////////
    func writeInSocket(dataDict: [String:Any]) {
        SocketManager.shared.server.clientSockets.forEach ({
            (socket) in
            do {
                let data = try JSONSerialization.data(withJSONObject: dataDict, options: [])
                print("transformou dicionario em data")
                do {
                    try socket.write(from: data)
                    print("escreveu no socket ==> \(dataDict)")
                } catch let (error) {
                    print(error)
                    print("Couldn't write in socket")
                }
            } catch let error {
                print(error)
                print("Error in conversion of dictionary to Data")
            }
        })
    }
    
    
    
    //// recebe coisas do servidor ////
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
    
    
    
    
    
    func decodeTxtRecord(toDictionary recordData: Data) -> [String:String] {
        
        let decodedData: [String:Data] = NetService.dictionary(fromTXTRecord: recordData)
        
        var decodedDictionary: [String:String] = [:]
        let keys = ["Name", "State", "Creator", "Ip", "Port"]
        
        for key in keys {
            decodedDictionary[key] = opDataToString(decodedData[key])
        }
        return decodedDictionary
    }
    /// funcao auxiliar da de cima /////
    func opDataToString(_ data:Data?)->String {
        if let decoded = data {
            return String(data:  decoded, encoding: String.Encoding.utf8) ?? ""
        }
        return ""
    }
    
    func decodeDictionary(toData dictionaryTxt: [String:String]) -> Data {
        print(dictionaryTxt)
        let jsonObject: [String: Data] = [
            "State": (dictionaryTxt["State"]?.data(using: .utf8))!,
            "Ip" : (dictionaryTxt["Ip"]?.data(using: .utf8))!,
            "Port" : (dictionaryTxt["Port"]?.data(using: .utf8))!
        ]
        
        let data = NetService.data(fromTXTRecord: jsonObject)
        
        return data
    }
}

extension SocketManager: ClientDelegate {
    
    /**
     Essa função inicializa o cliente para conseguir receber e trafegar dados
     - Version: 1.0 X Animes Edition
     - Important: Antes de enviar dados essa função é necessaria. Essa função não recebe parametros
     
     */
    func setUpClient() {
        client = Client()
        client.delegate = self
        client.searchForServerClient()
    }
    
    func didReceiveClientInfo(receivedDict: [String:Any]) {debugPrint(#function)
        print("recebeu Info")
        debugPrint("DICIONARIO =>>" , receivedDict)
    }
    
    func serviceFound(service: NetService) {debugPrint(#function)
        print(service.name)
        service.resolve(withTimeout: 10)
    }
    
    func didResolveService(resolvedNetService: NetService) {
        debugPrint(#function)
        debugPrint(resolvedNetService.txtRecordData())
        let txtRecord = resolvedNetService.txtRecordData()!
        print(txtRecord)
        
        bonjourDict = SocketManager.shared.decodeTxtRecord(toDictionary: txtRecord)
        print(bonjourDict)
        resolvedNetService.startMonitoring()
        let port = Int(bonjourDict["Port"]!)
        client.connect(ip: bonjourDict["Ip"]!, port: port!)
    }
    
    func didNotResolveService(netService: NetService) {debugPrint(#function)}
    
    func didUpdateTxtRecord(newData: Data) {debugPrint(#function)}
    
    //LOST SERVICE
    func didLostService(netService: NetService) {debugPrint(#function)}
    
}













