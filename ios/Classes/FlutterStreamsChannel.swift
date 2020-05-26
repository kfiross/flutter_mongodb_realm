//
//  FlutterStreamsChannel.swift
//  flutter_mongo_stitch
//
//  Created by kfir Matityahu on 25/04/2020.
//

import Foundation
import Flutter

struct FlutterStreamsChannelStream {
    var sink:FlutterEventSink
    var handler:FlutterStreamHandler
}

class FlutterStreamsChannel{
   
    
    var _messenger: FlutterBinaryMessenger;
    var _name:String = "";
    var _codec:FlutterMethodCodec ;
    
    init(name: String,
         binaryMessenger messenger : FlutterBinaryMessenger) {
        _name = name
        _messenger = messenger
        _codec = FlutterStandardMethodCodec.sharedInstance()
    }
    
    func setStreamHandlerFactory(factory: ((Any?) -> FlutterStreamHandler?)?){
        if (factory == nil) {
            _messenger.setMessageHandlerOnChannel(_name, binaryMessageHandler: nil)
            return;
        }
        
        var streams = Dictionary<String, AnyObject?>();
        let messageHandler:FlutterBinaryMessageHandler  =  {message, callback in

            let call = self._codec.decodeMethodCall(message!) // decodeMethodCall:message];
            let methodParts:Array = call.method.components(separatedBy: "#");
            
            if (methodParts.count != 2) {
                callback(nil);
                return;
            }
            
            let keyValue = Int(methodParts.last!)// NSNumber(pointer: );
            if(keyValue == 0) {
                callback(self._codec.encodeErrorEnvelope(FlutterError())) //:[FlutterError errorWithCode:@"error" message:[NSString stringWithFormat:@"Invalid method name: %@", call.method] details:nil]]);
                return;
            }
            
            var key = keyValue;
            
            
            if (methodParts.first == "listen"){//[methodParts.firstObject isEqualToString:@"listen"]) {
                //[self listenForCall:call withStreams:streams key:key usingCallback:callback andFactory:factory];
                self.listenForCall(call: call, withStreams: &streams, key: key!, usingCallback: callback, andFactory: factory!)
            } else if (methodParts.first == "cancel"){//[methodParts.firstObject isEqualToString:@"cancel"]) {
                self.cancelForCall(call: call, withStreams: &streams, key: key!, usingCallback: callback, andFactory: factory!)
                //[self cancelForCall:call withStreams:streams key:key usingCallback:callback andFactory:factory];
            } else {
                callback(nil);
            }
        };
        
         _messenger.setMessageHandlerOnChannel(_name, binaryMessageHandler: messageHandler)
    }
    
    
    func listenForCall(
        call: FlutterMethodCall,
        withStreams streams: inout [String: AnyObject?],
        key: Int,
        usingCallback callback: FlutterBinaryReply,
        andFactory factory:((Any?) -> FlutterStreamHandler?)
        ){
    
      
        var stream = streams[String(key)] as? FlutterStreamsChannelStream;
        if(stream != nil) {
            let error = stream!.handler.onCancel(withArguments: nil)
            if (error != nil) {
                print("Failed to cancel existing stream: \(error!.code) \(error!.message) (\(error!.details))")
            }
        }
        
        stream = FlutterStreamsChannelStream(sink: { event in
            let name = "\(self._name)#\(key)";
            
            if(event == nil){
                self._messenger.send(onChannel: name, message: self._codec.encodeSuccessEnvelope(nil))
            }
            else if (event as! NSObject == FlutterEndOfEventStream) {
                self._messenger.send(onChannel: name, message: nil)
            } else if (event is FlutterError){ //([event isKindOfClass:[FlutterError class]]) {
                self._messenger.send(onChannel: name, message: self._codec.encodeErrorEnvelope(event as! FlutterError))
            } else {
                self._messenger.send(onChannel: name, message: self._codec.encodeSuccessEnvelope(event))
            }
        }, handler: factory(call.arguments)!);

        streams[String(key)] = stream! as AnyObject

        
        let error = stream!.handler.onListen(withArguments: call.arguments, eventSink: stream!.sink)
        if (error != nil) {
            callback(self._codec.encodeErrorEnvelope(error!))
        } else {
            callback(self._codec.encodeSuccessEnvelope(nil))
        }
    }
    
    func cancelForCall(
        call: FlutterMethodCall,
        withStreams streams: inout [String: AnyObject?],
        key: Int,
        usingCallback callback: FlutterBinaryReply,
        andFactory factory:((Any?) -> FlutterStreamHandler?)
        ){

        let stream = streams[String(key)] as? FlutterStreamsChannelStream
        if(stream == nil) {
            callback(self._codec.encodeErrorEnvelope(
                FlutterError(code: "error", message: "No active stream to cancel", details: nil)
            ))
            return;
        }
    
    
        streams.removeValue(forKey: String(key))
        
        let error = stream!.handler.onCancel(withArguments: call.arguments)
        if (error != nil) {
            callback(self._codec.encodeErrorEnvelope(error!))
        } else {
            callback(self._codec.encodeSuccessEnvelope(nil))
        }
    }
}
