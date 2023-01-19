package com.example.flutter_mongo_stitch;

//  Copyright (c) 2018 Loup Inc.
//  Licensed under Apache License v2.0


import android.annotation.SuppressLint;
import android.util.Log;

import androidx.annotation.UiThread;

import java.nio.ByteBuffer;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicBoolean;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.BinaryMessenger.BinaryMessageHandler;
import io.flutter.plugin.common.BinaryMessenger.BinaryReply;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodCodec;
import io.flutter.plugin.common.StandardMethodCodec;
import io.realm.BuildConfig;

/**
 * Inspired from https://github.com/flutter/engine/blob/master/shell/platform/android/io/flutter/plugin/common/EventChannel.java
 */
public final class StreamsChannel {

    public interface StreamHandlerFactory {
        EventChannel.StreamHandler create(Object arguments);
    }

    private static final String TAG = "StreamsChannel#";

    private final BinaryMessenger messenger;
    private final String name;
    private final MethodCodec codec;

    public StreamsChannel(BinaryMessenger messenger, String name) {
        this(messenger, name, StandardMethodCodec.INSTANCE);
    }

    public StreamsChannel(BinaryMessenger messenger, String name, MethodCodec codec) {
        if (BuildConfig.DEBUG) {
            if (messenger == null) {
                Log.e(TAG, "Parameter messenger must not be null.");
            }
            if (name == null) {
                Log.e(TAG, "Parameter name must not be null.");
            }
            if (codec == null) {
                Log.e(TAG, "Parameter codec must not be null.");
            }
        }
        this.messenger = messenger;
        this.name = name;
        this.codec = codec;
    }

    @UiThread
    public void setStreamHandlerFactory(final StreamHandlerFactory factory) {
        messenger.setMessageHandler(name, factory == null ? null : new IncomingStreamRequestHandler(factory));
    }

    private final class IncomingStreamRequestHandler implements BinaryMessageHandler {
        private final StreamHandlerFactory factory;
        private final ConcurrentHashMap<Integer, Stream> streams = new ConcurrentHashMap<>();

        IncomingStreamRequestHandler(StreamHandlerFactory factory) {
            this.factory = factory;
        }

        @Override
        public void onMessage(ByteBuffer message, final BinaryReply reply) {
            final MethodCall call = codec.decodeMethodCall(message);
            final String[] methodParts = call.method.split("#");

            if (methodParts.length != 2) {
                reply.reply(null);
                return;
            }

            final int id;
            try {
                id = Integer.parseInt(methodParts[1]);
            } catch (NumberFormatException e) {
                reply.reply(codec.encodeErrorEnvelope("error", e.getMessage(), null));
                return;
            }

            final String method = methodParts[0];
            switch (method) {
                case "listen":
                    onListen(id, call.arguments, reply);
                    break;
                case "cancel":
                    onCancel(id, call.arguments, reply);
                    break;
                default:
                    reply.reply(null);
                    break;
            }
        }

        private void onListen(int id, Object arguments, BinaryReply callback) {
            final Stream stream = new Stream(new EventSinkImplementation(id), factory.create(arguments));
            final Stream oldStream = streams.putIfAbsent(id, stream);

            if (oldStream != null) {
                // Repeated calls to onListen may happen during hot restart.
                // We separate them with a call to onCancel.
                try {
                    oldStream.handler.onCancel(null);
                } catch (RuntimeException e) {
                    logError(id, "Failed to close existing event stream", e);
                }
            }

            try {
                stream.handler.onListen(arguments, stream.sink);
                callback.reply(codec.encodeSuccessEnvelope(null));
            } catch (RuntimeException e) {
                streams.remove(id);
                logError(id, "Failed to open event stream", e);
                callback.reply(codec.encodeErrorEnvelope("error", e.getMessage(), null));
            }
        }

        private void onCancel(int id, Object arguments, BinaryReply callback) {
            final Stream oldStream = streams.remove(id);

            if (oldStream != null) {
                try {
                    oldStream.handler.onCancel(arguments);
                    callback.reply(codec.encodeSuccessEnvelope(null));
                } catch (RuntimeException e) {
                    logError(id, "Failed to close event stream", e);
                    callback.reply(codec.encodeErrorEnvelope("error", e.getMessage(), null));
                }
            } else {
                callback.reply(codec.encodeErrorEnvelope("error", "No active stream to cancel", null));
            }
        }

        private void logError(int id, String message, Throwable e) {
            Log.e(TAG + name, String.format("%s [id=%d]", message, id), e);
        }

        private final class EventSinkImplementation implements EventChannel.EventSink {

            final int id;
            final String name;
            final AtomicBoolean hasEnded = new AtomicBoolean(false);

            @SuppressLint("DefaultLocale")
            private EventSinkImplementation(int id) {
                this.id = id;
                this.name = String.format("%s#%d", StreamsChannel.this.name, id);
            }

            @Override
            @UiThread
            public void success(Object event) {
                Stream stream = streams.get(id);
                if (hasEnded.get() || stream == null || stream.sink != this) {
                    return;
                }
                StreamsChannel.this.messenger.send(name, codec.encodeSuccessEnvelope(event));
            }

            @Override
            @UiThread
            public void error(String errorCode, String errorMessage, Object errorDetails) {
                Stream stream = streams.get(id);
                if (hasEnded.get() || stream == null || stream.sink != this) {
                    return;
                }
                StreamsChannel.this.messenger.send(
                        name,
                        codec.encodeErrorEnvelope(errorCode, errorMessage, errorDetails));
            }

            @Override
            @UiThread
            public void endOfStream() {
                Stream stream = streams.get(id);
                if (hasEnded.getAndSet(true) || stream == null || stream.sink != this) {
                    return;
                }
                StreamsChannel.this.messenger.send(name, null);
            }
        }
    }

    private static class Stream {
        final EventChannel.EventSink sink;
        final EventChannel.StreamHandler handler;

        private Stream(EventChannel.EventSink sink, EventChannel.StreamHandler handler) {
            this.sink = sink;
            this.handler = handler;
        }
    }
}
