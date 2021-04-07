//
//  SchnorrMusigError.swift
//  SchnorrMusigSDKSwift
//
//  Created by Eugene Belyakov on 04/04/2021.
//

import Foundation

enum SchnorrMusigError: Error {
    case invalidInputData
    case encodingError
    case signatureVerificationFailed
    case internalError
    case invalidPubkeyLength
    case nonceCommitmentNotGenerated
    case noncePrecommitmentsNotReceived
    case noncePrecommitmentsAndParticipantsNotMatch
    case nonceCommitmentsNotReceived
    case nonceCommitmentsAndParticipantsNotMatch
    case signatureShareAndParticipantsNotMatch
    case commitmentIsNotInCorrectSubgroup
    case invalidCommitment
    case invalidPublicKey
    case invalidParticipantPosition
    case aggregatedNonceCommitmentNotComputed
    case challengeNotGenerated
    case invalidSignatureShare
    case invalidSeed
    case unknown(UInt32)
    
    init(code: MusigRes) {
        switch code {
        case INVALID_INPUT_DATA:
            self = .invalidInputData
        case ENCODING_ERROR:
            self = .encodingError
        case SIGNATURE_VERIFICATION_FAILED:
            self = .signatureVerificationFailed
        case INTERNAL_ERROR:
            self = .internalError
        case INVALID_PUBKEY_LENGTH:
            self = .invalidPubkeyLength
        case NONCE_COMMITMENT_NOT_GENERATED:
            self = .nonceCommitmentNotGenerated
        case NONCE_PRECOMMITMENTS_NOT_RECEIVED:
            self = .noncePrecommitmentsNotReceived
        case NONCE_PRECOMMITMENTS_AND_PARTICIPANTS_NOT_MATCH:
            self = .noncePrecommitmentsAndParticipantsNotMatch
        case NONCE_COMMITMENTS_NOT_RECEIVED:
            self = .nonceCommitmentsNotReceived
        case NONCE_COMMITMENTS_AND_PARTICIPANTS_NOT_MATCH:
            self = .nonceCommitmentsAndParticipantsNotMatch
        case SIGNATURE_SHARE_AND_PARTICIPANTS_NOT_MATCH:
            self = .signatureShareAndParticipantsNotMatch
        case COMMITMENT_IS_NOT_IN_CORRECT_SUBGROUP:
            self = .commitmentIsNotInCorrectSubgroup
        case INVALID_COMMITMENT:
            self = .invalidCommitment
        case INVALID_PUBLIC_KEY:
            self = .invalidPublicKey
        case INVALID_PARTICIPANT_POSITION:
            self = .invalidParticipantPosition
        case AGGREGATED_NONCE_COMMITMENT_NOT_COMPUTED:
            self = .aggregatedNonceCommitmentNotComputed
        case CHALLENGE_NOT_GENERATED:
            self = .challengeNotGenerated
        case INVALID_SIGNATURE_SHARE:
            self = .invalidSignatureShare
        case INVALID_SEED:
            self = .invalidSeed
        default:
            self = .unknown(code.rawValue)
        }
    }
    
    var message: String {
        switch self {
        case .invalidInputData:
            return "Invalid input length"
        case .encodingError:
            return "Can't encode output"
        case .internalError:
            return "Internal error"
        case .signatureVerificationFailed:
            return "Failed to verify signature"
        case .invalidPubkeyLength:
            return "Public key length should be at least 1"
        case .nonceCommitmentNotGenerated:
            return "Nonce is not generated"
        case .noncePrecommitmentsNotReceived:
            return "Other parties' pre-commitments are not received yet"
        case .noncePrecommitmentsAndParticipantsNotMatch:
            return "Number of pre-commitments and participants does not match"
        case .nonceCommitmentsNotReceived:
            return "Other parties' commitment are not received yet"
        case .nonceCommitmentsAndParticipantsNotMatch:
            return "Number of commitments and participants does not match"
        case .signatureShareAndParticipantsNotMatch:
            return "Number of signature share and participants does not match"
        case .commitmentIsNotInCorrectSubgroup:
            return "Commitment is not in a correct subgroup"
        case .invalidCommitment:
            return "Commitments does not match with hash"
        case .invalidPublicKey:
            return "Invalid public key"
        case .invalidParticipantPosition:
            return "Position of signer does not match with number of parties"
        case .aggregatedNonceCommitmentNotComputed:
            return "Aggregated commitment is not computed"
        case .challengeNotGenerated:
            return "Challenge for fiat-shamir transform is not generated"
        case .invalidSignatureShare:
            return "Signature is not verified"
        case .invalidSeed:
            return "Seed length must be 128 bytes"
        default:
            return "Unknown error"
        }
    }
}
