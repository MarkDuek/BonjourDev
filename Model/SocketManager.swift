//
//  SocketManager.swift
//  BonjourDev
//
//  Created by Mark Duek on 27/09/18.
//  Copyright © 2018 Mark Duek. All rights reserved.
//

import Foundation
import Socket
/**
 Essa Classe gerencia as informações do Socket
 - Author: Mark Duek
 - Version: 0.1 Plus Ultra
 */
class SocketManager {
    //MARK: - Constantes e variaveis
    /**
     this constant is a singleton
 */
    static let shared: SocketManager = SocketManager()
    
    var server: Server!
    var client: Client!
    var isServer: Bool = false
    var isConnected: Bool = false
    var bonjourDict : [String:String]!
    
    var colorToChange: String!
}
    //MARK: - SocketManager extension para o servidor
extension SocketManager: ServerDelegate {
    
    //MARK: - Metodos do servidor
    /**
     Cria um servidor e o bota para funcionar.
     - Parameters:
        - name: String que da o nome para o serviço
 */
    func setUpServer(name: String) {
        server = Server()
        server.delegate = self
        self.isServer = true
        server.createService(lobbyName: name)
    }
    /**
     Essa funçao sempre roda quando o serviço é criado
*/
    func didCreateServer() {debugPrint(#function)
        let ip = Bonjour.shared.getWiFiAddress()
        let port = server.port
        debugPrint("tries to connect in Ip: \(ip!)")
        debugPrint("tries to connect in Port: \(String(describing: port))")
    }
    /**
        Essa função muda a bool para verdadeiro quando alguém conecta
     */
    func didConnectWithServer() {debugPrint(#function)
        isConnected = true
    }
    /**
     Escreve um Dicionario em todos os cliente contectados
     - Parameters:
        - dataDict: Dicionario que será escrito em cada cliente
     */
    func writeInSocket(dataDict: [String:Any]) {
        SocketManager.shared.server.clientSockets.forEach ({
            (socket) in
            do {
                let data = try JSONSerialization.data(withJSONObject: dataDict, options: [])
                debugPrint("transformou dicionario em data")
                do {
                    try socket.write(from: data)
                    debugPrint("escreveu no socket ==> \(dataDict)")
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
     Verifica a informação em forma de dicionario que o servidor recebeu e resolve ela
     - Parameters:
        -  receivedDict: É o dicionário que a função recebe para tratar
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
    
    //MARK: - Decoders
    func decodeTxtRecord(toDictionary recordData: Data) -> [String:String] {
        
        let decodedData: [String:Data] = NetService.dictionary(fromTXTRecord: recordData)
        
        var decodedDictionary: [String:String] = [:]
        let keys = ["Name", "State", "Creator", "Ip", "Port"]
        
        for key in keys {
            decodedDictionary[key] = opDataToString(decodedData[key])
        }
        return decodedDictionary
    }
    
    /**
     Essa função é auxiliar a função decodeTxtRecord
     Ela transforma data em String
     */
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

//MARK: - SocketManager extension para o client
extension SocketManager: ClientDelegate {
    
    //MARK: - Metodos do cliente
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
    /**
     Verifica as informaçoes que o cliente recebeu em forma de dicionario e as resolve
     - Parameters: Dicionario recebeido pela função para ser tratado
     */
    func didReceiveClientInfo(receivedDict: [String:Any]) {debugPrint(#function)
        debugPrint("recebeu Info")
        debugPrint("DICIONARIO =>>" , receivedDict)
    }
    /**
     Essa função ocorre toda vez que um serviço é encontrado
     */
    func serviceFound(service: NetService) {debugPrint(#function)
        debugPrint(service.name)
        service.resolve(withTimeout: 10)
    }
    /**
     Depois que o serviço é encontrado ele pega as informaçoes do bonjour e as bota no bounjourDict, permitindo que o cliente se conecte ao servidor que publicou essas informações na rede.
     */
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













