//
//  StitchFix.swift
//  flutter_mongodb_realm
//
//  Created by kfir Matit on 07/02/2021.
//
import StitchCore
import StitchCoreSDK

public struct FunctionCredential: StitchCredential {
    // MARK: Initializer

    /**
     * Initializes this credential with the name of the provider.
     */
    public init(payload: Document, withProviderName providerName: String = providerType.name) {
        self.providerName = providerName
        self.material = payload
    }

    // MARK: Properties

    /**
     * The name of the provider for this credential.
     */
    public var providerName: String

    /**
     * The type of the provider for this credential.
     */
    public static let providerType: StitchProviderType = .function

    /**
     * The contents of this credential as they will be passed to the Stitch server.
     */
    public var material: Document = [:]

    /**
     * The behavior of this credential when logging in.
     */
    public var providerCapabilities: ProviderCapabilities = ProviderCapabilities.init(reusesExistingSession: false)
}
