# Socket and Bonjour 

**By:** [Rodrigo Malhães Bukowitz ](https://github.com/rodrigomalhaesbuko) < rodrigomalhaes@gmail.com > [Mark Duek ](https://github.com/markduek) < duekmark@gmail.com > . 


## About This application 

To demonstrate a simple example of a Socket and Boujour use. We will comunicate an iOS app with a tvOS app, where the iOS app can change the color of the tvOS app. Our main goal here is to stablish a solid undertanding and a base project to start this type of comunication. 

*Note: This is only an example, with the code gathered in this project you can do so much more ( maybe a game if you like )*

In this project you have two applications, a tvOS and an iOS, that will be comunicating via Boujour and Socket. 
In our set up the tvOS will be placed as a Server and the iOS as the Client

## Good to Know

### Bonjour
Bonjour is a apple framework that let you publish information from an service ( in our case the server info ) in the network, enabling other devices to connect with this service. 

### Socket 
Socket is used in a client-server application, in order to create a connection between them. (in our case, the iOS and the tvOS application )

### Server 
The server is the host and uses Bonjour to publish all his info in the network enabling all the clients to connect with the server socket. After connecting he can send information to the clients.

### Client 
The client is the one that uses all the Bonjour info to connected with the server. Than the client can write and asks for informtion via Sockets. 

## To get started

To use the main features of the Socket we use an Pod called BlueSocket.

So you will need to install cocoa pods in your repository.

You can see more in...

[CocoaPods](https://cocoapods.org/)
[BlueSocket](https://github.com/IBM-Swift/BlueSocket)

## Additional Material 
We have done a series of videos on youtube explaning all the code step by step. 
Since we are Brazilian we have done the whole serie in portuguese, but you can use the auto-generated subtitles. 
[Bonjour and Socket Playlist ](https://www.youtube.com/playlist?list=PLWpneBiTMe-18aKLQ6xB4nn6TOVqmu0_E)



