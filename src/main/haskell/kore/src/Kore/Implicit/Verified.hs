{-|
Module      : Kore.Implicit.Verified
Description : Builds and verifies the implicit kore definitions.
Copyright   : (c) Runtime Verification, 2018
License     : NCSA
Maintainer  : virgil.serbanuta@runtimeverification.com
Stability   : experimental
Portability : POSIX
-}

module Kore.Implicit.Verified
    ( implicitKoreDefinition
    , implicitMetaDefinition
    )
    where

import Data.Proxy
       ( Proxy (..) )

import           Kore.AST.PureToKore
import           Kore.AST.Sentence
import           Kore.ASTVerifier.DefinitionVerifier
                 ( defaultAttributesVerification,
                 verifyImplicitKoreDefinition )
import           Kore.ASTVerifier.Error
                 ( VerifyError )
import qualified Kore.Attribute.Null as Attribute
import qualified Kore.Builtin as Builtin
import           Kore.Error
                 ( Error, printError )
import           Kore.Implicit.Definitions
                 ( uncheckedKoreDefinition, uncheckedMetaDefinition )
import           Kore.MetaML.AST

checkedMetaDefinition :: Either (Error VerifyError) MetaDefinition
checkedMetaDefinition = do
    _ <- verifyImplicitKoreDefinition
        attributesVerification
        Builtin.koreVerifiers
        (definitionPureToKore uncheckedMetaDefinition)
    return uncheckedMetaDefinition
  where
    attributesVerification =
        defaultAttributesVerification (Proxy :: Proxy Attribute.Null)

{-| 'implicitMetaDefinition' is a definition with everything Meta
that is implicitly defined and visible everywhere. This definition passes
validation checks.
-}
implicitMetaDefinition :: MetaDefinition
implicitMetaDefinition =
    case checkedMetaDefinition of
        Left err -> error (printError err)
        Right d  -> d

checkedKoreDefinition :: Either (Error VerifyError) KoreDefinition
checkedKoreDefinition = do
    _ <- verifyImplicitKoreDefinition
        attributesVerification
        Builtin.koreVerifiers
        uncheckedKoreDefinition
    return uncheckedKoreDefinition
  where
    attributesVerification =
        defaultAttributesVerification (Proxy :: Proxy Attribute.Null)

{-| 'implicitKoreDefinition' is a definition with everything
that is implicitly defined and visible everywhere. This definition passes
validation checks.
-}
implicitKoreDefinition :: KoreDefinition
implicitKoreDefinition =
    case checkedKoreDefinition of
        Left err -> error (printError err)
        Right d  -> d
